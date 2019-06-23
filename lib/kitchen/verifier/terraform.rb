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
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/fail_fast"
require "kitchen/terraform/config_attribute/systems"
require "kitchen/terraform/configurable"
require "kitchen/terraform/error"
require "kitchen/terraform/inspec_options_mapper"

module Kitchen
  # This namespace is defined by Kitchen.
  #
  # @see https://www.rubydoc.info/gems/test-kitchen/Kitchen/Verifier
  module Verifier
    # The verifier utilizes the {https://www.inspec.io/ InSpec infrastructure testing framework} to verify the behaviour and
    # state of resources in the Terraform state.
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
    # ===== Retrieving the Terraform Output
    #
    #   terraform output -json
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
    class Terraform < ::Kitchen::Verifier::Base
      include ::Kitchen::Terraform::ConfigAttribute::Color
      include ::Kitchen::Terraform::ConfigAttribute::FailFast
      include ::Kitchen::Terraform::ConfigAttribute::Systems
      include ::Kitchen::Terraform::Configurable
      kitchen_verifier_api_version 2

      attr_reader :inputs, :outputs

      # The verifier enumerates through each host of each system and verifies the associated InSpec controls.
      #
      # @example
      #   `kitchen verify suite-name`
      # @param _kitchen_state [::Hash] the mutable instance and verifier state.
      # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def call(_kitchen_state)
        load_variables
        verify_systems
        if !error_messages.empty?
          raise ::Kitchen::ActionFailed, error_messages.join("\n\n")
        end
      rescue ::Kitchen::Terraform::Error => error
        raise ::Kitchen::ActionFailed, error.message
      end

      # doctor checks the system and configuration for common errors.
      #
      # @param _kitchen_state [::Hash] the mutable Kitchen instance state.
      # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
      # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/verifier/base.rb#L85-L91
      def doctor(_kitchen_state)
        false
      end

      private

      attr_accessor :inspec_options_mapper, :error_messages
      attr_writer :inputs, :outputs

      def handle_error(message:)
        if config_fail_fast
          raise ::Kitchen::Terraform::Error, message
        else
          logger.error message
          error_messages.push message
        end
      end

      def load_variables
        instance.driver.retrieve_outputs do |outputs:|
          self.outputs.replace outputs
        end.retrieve_inputs do |inputs:|
          self.inputs.replace inputs
        end
      end

      def initialize(configuration = {})
        init_config configuration
        self.inspec_options_mapper = ::Kitchen::Terraform::InSpecOptionsMapper.new
        self.error_messages = []
        self.inputs = {}
        self.outputs = {}
      end

      # load_needed_dependencies! loads the InSpec libraries required to verify a Terraform state.
      #
      # @raise [::Kitchen::ClientError] if loading the InSpec libraries fails.
      # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/configurable.rb#L252-L274
      def load_needed_dependencies!
        require "kitchen/terraform/inspec"
        require "kitchen/terraform/system"
        ::Kitchen::Terraform::InSpec.logger = logger
      rescue ::LoadError => load_error
        raise ::Kitchen::ClientError, load_error.message
      end

      def system_inspec_options(system:)
        inspec_options_mapper.map(options: { "color" => config_color, "distinct_exit" => false }, system: system)
      end

      def verify(system:)
        ::Kitchen::Terraform::System.new(
          mapping: { profile_locations: [::File.join(config.fetch(:test_base_path), instance.suite.name)] }
            .merge(system),
        ).verify(inputs: inputs, inspec_options: system_inspec_options(system: system), outputs: outputs)
      rescue => error
        handle_error message: error.message
      end

      def verify_systems
        config_systems.each do |system|
          verify system: system
        end
      end
    end
  end
end
