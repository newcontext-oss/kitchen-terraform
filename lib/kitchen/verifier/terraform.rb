# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
require "kitchen/terraform/raise/client_error"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/fail_fast"
require "kitchen/terraform/config_attribute/systems"
require "kitchen/terraform/configurable"
require "kitchen/terraform/systems_verifier_factory"
require "kitchen/terraform/outputs_manager"
require "kitchen/terraform/variables_manager"

module Kitchen
  # This namespace is defined by Kitchen.
  #
  # @see https://www.rubydoc.info/gems/test-kitchen/Kitchen/Verifier
  module Verifier
    # The verifier utilizes the {https://www.inspec.io/ InSpec infrastructure testing framework} to verify the
    # behaviour and state of resources in the Terraform state.
    #
    # === Commands
    #
    # The following command-line commands are provided by the verifier.
    #
    # ==== kitchen verify
    #
    # A Kitchen instance is verified by iterating through the systems and executing the associated InSpec controls
    # against the hosts of each system. The outputs of the Terraform state are retrieved and exposed as attributes to
    # the InSpec controls.
    #
    # === Configuration Attributes
    #
    # The configuration attributes of the verifier control the behaviour of the InSpec runner. Within the
    # {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}, these attributes must be
    # declared in the +verifier+ mapping along with the plugin name.
    #
    #   verifier:
    #     name: terraform
    #     a_configuration_attribute: some value
    #
    # ==== color
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Color}
    #
    # ==== fail_fast
    #
    # {include:Kitchen::Terraform::ConfigAttribute::FailFast}
    #
    # ==== systems
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Systems}
    #
    # === Ruby Interface
    #
    # This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
    # :reek:MissingSafeMethod { exclude: [ finalize_config!, load_needed_dependencies! ] }
    #
    # @example Describe the verify command
    #   kitchen help verify
    # @example Verify a Test Kitchen instance
    #   kitchen verify default-ubuntu
    # @version 2
    class Terraform < ::Kitchen::Verifier::Base
      # UNSUPPORTED_BASE_ATTRIBUTES is the list of attributes inherited from
      # Kitchen::Verifier::Base which are not supported by Kitchen::Verifier::Terraform.
      UNSUPPORTED_BASE_ATTRIBUTES = [
        :chef_omnibus_root,
        :command_prefix,
        :http_proxy,
        :https_proxy,
        :ftp_proxy,
        :root_path,
        :sudo,
        :sudo_command,
      ]
      defaults.delete_if do |key|
        UNSUPPORTED_BASE_ATTRIBUTES.include? key
      end
      include ::Kitchen::Terraform::ConfigAttribute::Color
      include ::Kitchen::Terraform::ConfigAttribute::FailFast
      include ::Kitchen::Terraform::ConfigAttribute::Systems
      include ::Kitchen::Terraform::Configurable
      kitchen_verifier_api_version 2

      attr_reader :outputs, :variables

      # The verifier enumerates through each host of each system and verifies the associated InSpec controls.
      #
      # @example
      #   `kitchen verify suite-name`
      # @param state [Hash] the mutable instance and verifier state.
      # @raise [Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def call(state)
        load_variables state: state
        load_outputs state: state
        verify_systems
      rescue => error
        action_failed.call message: error.message
      end

      # doctor checks the system and configuration for common errors.
      #
      # @param _state [Hash] the mutable Kitchen instance state.
      # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
      # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/verifier/base.rb#L85-L91
      def doctor(_state)
        false
      end

      # #initialize prepares a new instance of the class.
      #
      # @param config [Hash] the verifier configuration.
      # @return [Kitchen::Verifier::Terraform]
      def initialize(config = {})
        init_config config
        self.action_failed = ::Kitchen::Terraform::Raise::ActionFailed.new logger: logger
        self.client_error = ::Kitchen::Terraform::Raise::ClientError.new logger: logger
        self.outputs = {}
        self.variables = {}
      end

      private

      attr_accessor :action_failed, :client_error, :outputs, :variables

      def load_variables(state:)
        logger.warn "Reading the Terraform input variables from the Kitchen instance state..."
        ::Kitchen::Terraform::VariablesManager.new.load variables: variables, state: state
        logger.warn "Finished reading the Terraform input variables from the Kitchen instance state."
      end

      # load_needed_dependencies! loads the InSpec libraries required to verify a Terraform state.
      #
      # @raise [Kitchen::ClientError] if loading the InSpec libraries fails.
      # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/configurable.rb#L252-L274
      def load_needed_dependencies!
        require "kitchen/terraform/inspec_runner"
        require "kitchen/terraform/system"
        ::Kitchen::Terraform::InSpecRunner.logger = logger
      rescue ::LoadError => load_error
        client_error.call message: load_error.message
      end

      def load_outputs(state:)
        logger.warn "Reading the Terraform output variables from the Kitchen instance state..."
        ::Kitchen::Terraform::OutputsManager.new.load outputs: outputs, state: state
        logger.warn "Finished reading the Terraform output varibales from the Kitchen instance state."
      end

      def profile_locations
        @profile_locations ||= [::File.join(config.fetch(:test_base_path), instance.suite.name)]
      end

      def systems
        @systems ||= config_systems.map do |system|
          ::Kitchen::Terraform::System.new(
            configuration_attributes: { color: config_color, profile_locations: profile_locations }.merge(system),
            logger: logger,
          )
        end
      end

      def systems_verifier
        @systems_verifier ||= ::Kitchen::Terraform::SystemsVerifierFactory.new(fail_fast: config_fail_fast).build(
          systems: systems,
        )
      end

      def verify_systems
        logger.warn "Verifying the systems..."
        systems_verifier.verify outputs: outputs, variables: variables
        logger.warn "Finished verifying the systems."
      end
    end
  end
end
