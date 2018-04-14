# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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
require "kitchen/terraform/client"
require "kitchen/terraform/config_attribute/backend_configurations"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/command_timeout"
require "kitchen/terraform/config_attribute/lock"
require "kitchen/terraform/config_attribute/lock_timeout"
require "kitchen/terraform/config_attribute/parallelism"
require "kitchen/terraform/config_attribute/plugin_directory"
require "kitchen/terraform/config_attribute/root_module_directory"
require "kitchen/terraform/config_attribute/variable_files"
require "kitchen/terraform/config_attribute/variables"
require "kitchen/terraform/configurable"
require "shellwords"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Driver
module ::Kitchen::Driver
end

# The driver is the bridge between Kitchen and Terraform. It manages the
# {https://www.terraform.io/docs/state/index.html Terraform state} of a
# {https://kitchen.ci/docs/getting-started/instances Kitchen Instance} based on the Terraform configuration of the
# associated Terraform root module. 
#
# === Command-Line Interface
#
# The following actions are implemented by the driver:
#
# * {#create kitchen create}
#
# * {#destroy kitchen destroy}
#
# === Enable the Plugin
# The +driver+ mapping must be declared with the plugin name within the
# {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}.
#
#   driver:
#     name: terraform
#
# === Configuration
#
# The configuration of the driver controls the behaviour of the Terraform commands that are executed.
#
# ==== backend_configurations
#
# {include:Kitchen::Terraform::ConfigAttribute::BackendConfigurations}
#
# ==== color
#
# {include:Kitchen::Terraform::ConfigAttribute::Color}
#
# ==== command_timeout
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
# === Running Terraform Commands
#
# {include:Kitchen::Terraform::Client}
class ::Kitchen::Driver::Terraform < ::Kitchen::Driver::Base
  kitchen_driver_api_version 2

  include ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations

  include ::Kitchen::Terraform::ConfigAttribute::Color

  include ::Kitchen::Terraform::ConfigAttribute::CommandTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Lock

  include ::Kitchen::Terraform::ConfigAttribute::LockTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Parallelism

  include ::Kitchen::Terraform::ConfigAttribute::PluginDirectory

  include ::Kitchen::Terraform::ConfigAttribute::RootModuleDirectory

  include ::Kitchen::Terraform::ConfigAttribute::VariableFiles

  include ::Kitchen::Terraform::ConfigAttribute::Variables

  include ::Kitchen::Terraform::Configurable

  attr_writer :client

  # This method queries for the names of the action methods which must be run in serial via a shared mutex.
  #
  # If the version satisfies the requirement of ~> 3.3 then no names are returned.
  #
  # If the version satisfies the requirement of >= 4 then +:create+, +:converge+, +:setup+, and +:destroy+ are returned.
  #
  # @param version [::Kitchen::Terraform::Version] the version to compare against the requirements.
  # @return [::Array<Symbol>] the action method names.
  def self.serial_actions(version: ::Kitchen::Terraform::Version.new)
    version
      .if_satisfies requirement: ::Gem::Requirement.new("~> 3.3") do
        no_parallel_for
      end

    version
      .if_satisfies requirement: ::Gem::Requirement.new(">= 4") do
        super()
          .empty? and
          no_parallel_for(
            :create,
            :converge,
            :setup,
            :destroy
          )
      end

    super()
  end

  # This action creates the Kitchen Instance by preparing the Terraform working directory .
  #
  # === Workflow
  #
  # ==== Initializing the Terraform Working Directory
  #
  #   terraform init \
  #     -backend=true \
  #     -force-copy \
  #     -get-plugins=true \
  #     -get=true \
  #     -input=false \
  #     -upgrade \
  #     -verify-plugins=true \
  #     [-backend-config=<backend_configurations.first> ...] \
  #     -lock-timeout=<lock_timeout>s \
  #     -lock=<lock> \
  #     [-no-color] \
  #     [-plugin-dir=<plugin_directory>] \
  #     <root_module_directory>
  #
  # ==== Creating a Test Terraform Workspace
  #
  #   terraform workspace <select|new> kitchen-terraform-<instance>
  #
  # @example Describe the create action
  #   kitchen help create
  # @example Create a Kitchen Instance named default-ubuntu
  #   kitchen create default-ubuntu
  # @param _kitchen_state [::Hash] the Kitchen state is not manipulated by this action.
  # @raise [::Kitchen::ActionFailed] if the Terraform working directory can not be initialized; if the test Terraform
  #   workspace can not be selected or created.
  # @return [self]
  def create(_kitchen_state)
    client.init_with_upgrade flags: init_flags
    client.select_or_create_kitchen_instance_workspace
  rescue => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end

  # This action destroys the Kitchen Instance by destroying the Terraform state.
  #
  # === Worklflow
  #
  # ==== Initializing the Terraform Working Directory
  #
  # The Terraform working directory is initialized using the Terraform configuration. This behaviour is necessary to
  # support the +kitchen test+ action being executed against an uninitialized Terraform working directory, as it invokes
  # this action before +kitchen create+.
  #
  #   terraform init \
  #     -backend=true \
  #     -force-copy \
  #     -get-plugins=true \
  #     -get=true \
  #     -input=false \
  #     -verify-plugins=true \
  #     [-backend-config=<backend_configurations.first>...] \
  #     -lock-timeout=<lock_timeout>s \
  #     -lock=<lock> \
  #     [-no-color] \
  #     [-plugin-dir=<plugin_directory>] \
  #     <root_module_directory>
  #
  # ==== Selecting the Test Terraform Workspace
  #
  #   terraform workspace <select|new> kitchen-terraform-<instance>
  #
  # ==== Destroying the Terraform State
  #
  #   terraform destroy \
  #     -force \
  #     -input=false \
  #     -refresh=true \
  #     -lock=<lock> \
  #     -lock-timeout=<lock_timeout>s \
  #     [-no-color] \
  #     -parallelism=<parallelism> \
  #     [-var-file=<variable_files.first>...] \
  #     [-var=<variables.first>...] \
  #     <root_module_directory>
  #
  # ==== Selecting the Default Terraform Workspace
  #
  #   terraform workspace select default
  #
  # ==== Deleting the Test Terraform Workspace
  #
  #   terraform workspace delete kitchen-terraform-<instance>
  #
  # @example Describe the destroy action
  #   kitchen help destroy
  # @example Destroy a Kitchen Instance named default-ubuntu
  #   kitchen destroy default-ubuntu
  # @param _kitchen_state [::Hash] the Kitchen state is not manipulated by this action.
  # @raise [::Kitchen::ActionFailed] if the Terraform working directory can not be initialized; if the test Terraform
  #   workspace can not be selected or created; if the Terraform state can not be destroyed; if the default Terraform
  #   workspace can not be selected; if the test Terraform workspace can not be deleted.
  # @return [void]
  def destroy(_kitchen_state)
    client.init flags: init_flags
    client.select_or_create_kitchen_instance_workspace
    client.destroy flags: destroy_flags
    client.select_default_workspace
    client.delete_kitchen_instance_workspace
  rescue => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end

  # This method extends {::Kitchen::Terraform::Configurable#finalize_config!} to configure the
  # the Terraform client with a Kitchen instance name and a root module directory.
  #
  # @param kitchen_instance [::Kitchen::Instance] 
  # @return [self]
  def finalize_config!(kitchen_instance)
    super kitchen_instance
    client.workspace_name = kitchen_instance.name
    client.root_module_directory = root_module_directory
    client.timeout = config_command_timeout
    self
  end

  # Verifies that the Terraform version available to the driver is supported.
  #
  # @note This method is invoked before the configuration is validated so it must not depend on any configuration
  #   attributes.
  # @raise [::Kitchen::ShellOut::ShellCommandFailed] if a shell command fails.
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @return [void]
  def verify_dependencies
    client
      .if_version_not_supported do |message:|
        raise(
          ::Kitchen::UserError,
          message
        )
      end
  rescue => error
    raise(
      ::Kitchen::UserError,
      error.message
    )
  end

  private

  # @api private
  def backend_configurations_flags
    config_backend_configurations
      .map do |key, value|
        "-backend-config=#{::Shellwords.escape "#{key}=#{value}"}"
      end
      .join " "
  end

  # api private
  def color_flag
    config_color and "" or "-no-color"
  end

  attr_reader :client

  # @api private
  def destroy_flags
    [
      lock_timeout_flag,
      lock_flag,
      color_flag,
      parallelism_flag,
      variable_files_flags,
      variables_flags
    ]
  end

  # @api private
  def init_flags
    [
      backend_configurations_flags,
      lock_timeout_flag,
      lock_flag,
      color_flag,
      plugin_directory_flag
    ]
  end

  # This method extends
  # {http://www.rubydoc.info/gems/test-kitchen/1.20.0/Kitchen%2FDriver%2FBase:initialize Kitchen::Driver::Base#initialize}
  # to instantiate and partially configure a Terraform client.
  # @api private
  # @return [self]
  def initialize(config = {})
    super config
    self.client = ::Kitchen::Terraform::Client.new
    client.logger = logger
    self
  end

  # @api private
  def lock_flag
    "-lock=#{config_lock}"
  end

  # @api private
  def lock_timeout_flag
    "-lock-timeout=#{config_lock_timeout}s"
  end

  # @api private
  def parallelism_flag
    "-parallelism=#{config_parallelism}"
  end

  # @api private
  def plugin_directory_flag
    config_plugin_directory and
      "-plugin-dir=#{::Shellwords.escape config_plugin_directory}" or
      ""
  end

  # @api private
  def root_module_directory
    ::Shellwords.escape config_root_module_directory
  end

  # @api private
  def variable_files_flags
    config_variable_files
      .map do |path|
        "-var-file=#{::Shellwords.escape path}"
      end
      .join " "
  end

  # @api private
  def variables_flags
    config_variables
      .map do |key, value|
        "-var=#{::Shellwords.escape "#{key}=#{value}"}"
      end
      .join " "
  end
end
