# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "kitchen"
require "kitchen/terraform/raise/action_failed"
require "kitchen/terraform/config_attribute/backend_configurations"
require "kitchen/terraform/config_attribute/client"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/command_timeout"
require "kitchen/terraform/config_attribute/lock_timeout"
require "kitchen/terraform/config_attribute/lock"
require "kitchen/terraform/config_attribute/parallelism"
require "kitchen/terraform/config_attribute/plugin_directory"
require "kitchen/terraform/config_attribute/root_module_directory"
require "kitchen/terraform/config_attribute/variable_files"
require "kitchen/terraform/config_attribute/variables"
require "kitchen/terraform/config_attribute/verify_version"
require "kitchen/terraform/configurable"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/driver/destroy"
require "kitchen/terraform/version_verifier"
require "kitchen/transport/terraform"
require "rubygems"
require "shellwords"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen
module Kitchen
  # This namespace is defined by Kitchen.
  #
  # @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Driver
  module Driver

    # The Terraform driver is the bridge between Test Kitchen and Terraform. It manages the
    # {https://developer.hashicorp.com/terraform/language/state state} of the Terraform root module under test by
    # shelling out and running Terraform commands.
    #
    # === Commands
    #
    # The following command-line commands are provided by the driver.
    #
    # ==== kitchen create
    #
    # {include:Kitchen::Terraform::Driver::Create}
    #
    # ==== kitchen destroy
    #
    # {include:Kitchen::Terraform::Driver::Destroy}
    #
    # === Configuration Attributes
    #
    # The configuration attributes of the driver control the behaviour of the Terraform commands that are run. Within the
    # {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}, these attributes must be
    # declared in the +driver+ mapping along with the plugin name.
    #
    #   driver:
    #     name: terraform
    #     a_configuration_attribute: some value
    #
    # ==== backend_configurations
    #
    # {include:Kitchen::Terraform::ConfigAttribute::BackendConfigurations}
    #
    # ==== client
    #
    # driver.client is deprecated; use transport.client instead.
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Client}
    #
    # ==== color
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Color}
    #
    # ==== command_timeout
    #
    # driver.command_timeout is deprecated; use transport.command_timeout instead.
    #
    # {include:Kitchen::Terraform::ConfigAttribute::CommandTimeout}
    #
    # ==== lock
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Lock}
    #
    # ==== lock_timeout
    #
    # {include:Kitchen::Terraform::ConfigAttribute::LockTimeout}
    #
    # ==== parallelism
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Parallelism}
    #
    # ==== plugin_directory
    #
    # {include:Kitchen::Terraform::ConfigAttribute::PluginDirectory}
    #
    # ==== root_module_directory
    #
    # driver.root_module_directory is deprecated; use transport.root_module_directory instead.
    #
    # {include:Kitchen::Terraform::ConfigAttribute::RootModuleDirectory}
    #
    # ==== variable_files
    #
    # {include:Kitchen::Terraform::ConfigAttribute::VariableFiles}
    #
    # ==== variables
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Variables}
    #
    # ==== verify_version
    #
    # {include:Kitchen::Terraform::ConfigAttribute::VerifyVersion}
    #
    # === Ruby Interface
    #
    # This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
    # :reek:MissingSafeMethod { exclude: [ finalize_config! ] }
    #
    # @example Describe the create command
    #   kitchen help create
    # @example Create a Test Kitchen instance
    #   kitchen create default-ubuntu
    # @example Describe the destroy command
    #   kitchen help destroy
    # @example Destroy a Test Kitchen instance
    #   kitchen destroy default-ubuntu
    # @version 2
    class Terraform < ::Kitchen::Driver::Base
      kitchen_driver_api_version 2

      include ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations

      include ::Kitchen::Terraform::ConfigAttribute::Client
      deprecate_config_for :client, "use transport.client instead"

      include ::Kitchen::Terraform::ConfigAttribute::Color

      include ::Kitchen::Terraform::ConfigAttribute::CommandTimeout
      deprecate_config_for :command_timeout, "use transport.command_timeout instead"

      include ::Kitchen::Terraform::ConfigAttribute::Lock

      include ::Kitchen::Terraform::ConfigAttribute::LockTimeout

      include ::Kitchen::Terraform::ConfigAttribute::Parallelism

      include ::Kitchen::Terraform::ConfigAttribute::PluginDirectory

      include ::Kitchen::Terraform::ConfigAttribute::RootModuleDirectory
      deprecate_config_for :root_module_directory, "use transport.root_module_directory instead"

      include ::Kitchen::Terraform::ConfigAttribute::VariableFiles

      include ::Kitchen::Terraform::ConfigAttribute::Variables

      include ::Kitchen::Terraform::ConfigAttribute::VerifyVersion

      include ::Kitchen::Terraform::Configurable

      attr_reader :transport

      # Creates a Test Kitchen instance by initializing the working directory and creating a test workspace.
      #
      # @param state [Hash] the mutable instance and driver state.
      # @raise [Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def create(state)
        ::Kitchen::Terraform::Driver::Create.new(
          config: config,
          connection: transport.connection(state),
          logger: logger,
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        ).call
      rescue => error
        action_failed.call message: error.message
      end

      # Destroys a Test Kitchen instance by initializing the working directory, selecting the test workspace,
      # deleting the state, selecting the default workspace, and deleting the test workspace.
      #
      # @param state [Hash] the mutable instance and driver state.
      # @raise [Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def destroy(state)
        ::Kitchen::Terraform::Driver::Destroy.new(
          config: config,
          connection: transport.connection(state.merge(environment: { "TF_WARN_OUTPUT_ERRORS" => "true" })),
          logger: logger,
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        ).call
      rescue => error
        action_failed.call message: error.message
      end

      # doctor checks the system and configuration for common errors.
      #
      # @param state [Hash] the mutable Kitchen instance state.
      # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
      def doctor(state)
        errors = false

        deprecated_config.each_pair do |attribute, message|
          errors = true
          logger.warn "driver.#{attribute} is deprecated: #{message}"
        end

        methods.each do |method|
          next if !method.match? /doctor_config_.*/

          config_error = send method
          errors = errors || config_error
        end

        transport_errors = transport.doctor state
        verifier_errors = instance.verifier.doctor state

        errors || transport_errors || verifier_errors
      end

      # #finalize_config! invokes the super implementation and then initializes the strategies.
      #
      # @param instance [Kitchen::Instance] an associated instance.
      # @raise [Kitchen::ClientError] if the instance is nil.
      # @return [self]
      def finalize_config!(instance)
        super

        self.deprecated_config ||= {}

        transport = instance.transport

        self.transport = if ::Kitchen::Transport::Terraform == transport.class
            transport
          else
            ::Kitchen::Transport::Terraform.new(config).finalize_config! instance
          end

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param config [Hash] the driver configuration.
      # @return [Kitchen::Driver::Terraform]
      def initialize(config = {})
        super config
        self.action_failed = ::Kitchen::Terraform::Raise::ActionFailed.new logger: logger
      end

      private

      attr_accessor :action_failed, :deprecated_config
      attr_writer :transport
    end
  end
end
