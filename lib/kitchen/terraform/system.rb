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

require "kitchen/terraform/inspec_factory"
require "kitchen/terraform/inspec_options_factory"
require "kitchen/terraform/system_attrs_inputs_resolver"
require "kitchen/terraform/system_attrs_outputs_resolver"
require "kitchen/terraform/system_hosts_resolver"

module Kitchen
  module Terraform
    # System is the class of objects which are verified by the Terraform Verifier.
    class System
      # #initialize prepares a new instance of the class.
      #
      # @param configuration_attributes [::Hash] a mapping of configuration attributes.
      # @param logger [::Kitchen::Logger] a logger to log messages.
      def initialize(configuration_attributes:, logger:)
        self.attrs_outputs = configuration_attributes.fetch :attrs_outputs do
          {}
        end.dup
        self.configuration_attributes = configuration_attributes
        self.hosts = configuration_attributes.fetch :hosts do
          []
        end.dup
        self.inspec_options_factory = ::Kitchen::Terraform::InSpecOptionsFactory.new
        self.logger = logger
      end

      # @return [::String] a string representation of the system.
      def to_s
        configuration_attributes.fetch(:name).dup
      end

      # #verify verifies the system by executing InSpec.
      #
      # @param fail_fast [Boolean] a toggle to control the fast or slow failure of InSpec.
      # @param outputs [::Hash] the Terraform outputs to be utilized as InSpec profile attributes.
      # @param variables [::Hash] the Terraform variables to be utilized as InSpec profile attributes.
      # @return [self]
      def verify(fail_fast:, outputs:, variables:)
        logger.info "Starting verification of the '#{self}' system."
        resolve outputs: outputs, variables: variables do |attrs:|
          ::Kitchen::Terraform::InSpecFactory.new(fail_fast: fail_fast, hosts: hosts).build(
            logger: logger,
            options: inspec_options_factory.build(
              attributes: attrs,
              system_configuration_attributes: configuration_attributes,
            ),
            profile_locations: configuration_attributes.fetch(:profile_locations),
          ).exec
        end
        logger.info "Finished verification of the '#{self}' system."

        self
      end

      private

      attr_accessor :attrs_outputs, :configuration_attributes, :hosts, :inspec_options_factory, :logger

      def resolve(outputs:, variables:, &block)
        resolve_hosts outputs: outputs if configuration_attributes.key? :hosts_output
        resolve_attrs outputs: outputs, variables: variables, &block
      end

      def resolve_attrs(outputs:, variables:, &block)
        ::Kitchen::Terraform::SystemAttrsInputsResolver.new(attrs: {}).resolve inputs: variables do |attrs:|
          ::Kitchen::Terraform::SystemAttrsOutputsResolver.new(attrs: attrs, logger: logger).resolve(
            attrs_outputs: attrs_outputs,
            outputs: outputs,
            &block
          )
        end
      end

      def resolve_hosts(outputs:)
        ::Kitchen::Terraform::SystemHostsResolver.new(logger: logger, outputs: outputs).resolve(
          hosts: hosts,
          hosts_output: configuration_attributes.fetch(:hosts_output),
        )

        self
      end
    end
  end
end
