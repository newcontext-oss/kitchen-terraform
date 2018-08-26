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
require "kitchen/terraform/config_attribute/systems"
require "kitchen/terraform/configurable"
require "kitchen/terraform/error"
require "kitchen/terraform/inspec_options_mapper"
require "kitchen/terraform/system_attrs_resolver"
require "kitchen/terraform/system_hosts_resolver"

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
    # A Test Kitchen instance is verified by iterating through the systems and executing the associated InSpec controls
    # against the hosts of each system.
    #
    # ==== kitchen doctor
    #
    # Checks the system and the Kitchen configuration for common errors.
    #
    # ===== Describing the command
    #
    #   kitchen help doctor
    #
    # ===== Checking for errors
    #
    #   kitchen doctor
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
    # ==== systems
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Systems}
    #
    # === Ruby Interface
    #
    # This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
    # :reek:PrimaDonnaMethod { exclude: [ finalize_config!, load_needed_dependencies! ] }
    class Terraform
      include ::Kitchen::Configurable
      include ::Kitchen::Logging
      include ::Kitchen::Terraform::ConfigAttribute::Color
      include ::Kitchen::Terraform::ConfigAttribute::Systems
      include ::Kitchen::Terraform::Configurable
      @api_version = 2

      deprecate_config_for :groups,
                           "The systems configuration attribute replaces groups.\nRead the systems " \
                           "documentation at: https://www.rubydoc.info/gems/kitchen-terraform/Kitchen/Terraform/ConfigAttribute/Systems"

      # The verifier enumerates through each host of each system and verifies the associated InSpec controls.
      #
      # @example
      #   `kitchen verify suite-name`
      # @param kitchen_state [::Hash] the mutable instance and verifier state.
      # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def call(kitchen_state)
        load_outputs kitchen_state: kitchen_state
        config_systems.each do |system|
          verify system: system
        end
      rescue ::Kitchen::Terraform::Error => error
        raise ::Kitchen::ActionFailed, error.message
      end

      # finalize_config! configures InSpec options which remain consistent between systems.
      #
      # @param kitchen_instance [::Kitchen::Instance] an associated Kitchen instance.
      # @return [self]
      def finalize_config!(kitchen_instance)
        super kitchen_instance
        configure_inspec_connection_options
        configure_inspec_miscellaneous_options
      end

      private

      def configure_inspec_connection_options
        @inspec_options.merge! transport_connection_options

        @inspec_options
          .store(
            "connection_timeout",
            @inspec_options.delete("timeout")
          )
      end

      def configure_inspec_miscellaneous_options
        @inspec_options.merge!(
          "color" => config_color,
          "distinct_exit" => false,
          "sudo" => false,
          "sudo_command" => "sudo -E",
          "sudo_options" => "",
        )
      end

      def configure_inspec_system_options(system:)
        ::Kitchen::Terraform::InSpecOptionsMapper.new(system: system).map options: @inspec_options
      end

      def load_outputs(kitchen_state:)
        @outputs = ::Kitchen::Util.stringified_hash Hash kitchen_state.fetch :kitchen_terraform_outputs
      rescue ::KeyError => key_error
        raise ::Kitchen::Terraform::Error,
              "Loading Terraform outputs from the Kitchen state failed; this implies that the " \
              "Kitchen-Terraform provisioner has not successfully converged\n#{key_error}"
      end

      def initialize(configuration = {})
        init_config configuration
        @inspec_options = {}
        @outputs = {}
        @transport_attributes = [
          :compression, :compression_level, :connection_retries, :connection_retry_sleep, :connection_timeout,
          :keepalive, :keepalive_interval, :max_wait_until_ready,
        ]
      end

      def inspec_profile_path
        @inspec_profile_path ||= ::File.join config.fetch(:test_base_path), instance.suite.name
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

      def system_attrs_resolver
        @system_attrs_resolver ||= ::Kitchen::Terraform::SystemAttrsResolver.new outputs: @outputs
      end

      def system_hosts_resolver
        @system_hosts_resolver ||= ::Kitchen::Terraform::SystemHostsResolver.new outputs: @outputs
      end

      def transport_connection_options
        ::Kitchen::Util.stringified_hash(
          instance.transport.diagnose.select do |key|
            @transport_attributes.include? key
          end.tap do |options|
            options.store :timeout, options.fetch(:connection_timeout)
          end
        )
      end

      def verify(system:)
        configure_inspec_system_options system: system
        ::Kitchen::Terraform::System
          .new(mapping: system)
          .resolve_attrs(system_attrs_resolver: system_attrs_resolver)
          .resolve_hosts(system_hosts_resolver: system_hosts_resolver)
          .verify(inspec_options: @inspec_options, inspec_profile_path: inspec_profile_path)
      end
    end
  end
end
