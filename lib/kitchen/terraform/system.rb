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
      # @param logger [Kitchen::Logger] a logger to log messages.
      # @option configuration_attributes [Hash{String=>String}] :attrs_outputs a mapping of InSpec attribute names to
      #   Terraform output names
      # @option configuration_attributes [Array<String>] :hosts a list of static hosts in the system.
      # @option configuration_attributes [String] :hosts_output the name of a Terraform output which contains one or
      #   more hosts in the system.
      # @option configuration_attributes [String] :name the name of the system.
      # @option configuration_attributes [Array<String>] :profile_locations a list of the locations of InSpec profiles.
      # @return [Kitchen::Terraform::System]
      def initialize(configuration_attributes:, logger:)
        self.attrs = {}
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

      # @return [String] a string representation of the system.
      def to_s
        configuration_attributes.fetch(:name).dup
      end

      # #verify verifies the system by executing InSpec.
      #
      # @param fail_fast [Boolean] a toggle to control the fast or slow failure of InSpec.
      # @param outputs [Hash] the Terraform outputs to be utilized as InSpec profile attributes.
      # @param variables [Hash] the Terraform variables to be utilized as InSpec profile attributes.
      # @raise [Kitchen::ClientError, Kitchen::TransientFailure] if verifying the system fails.
      # @return [self]
      def verify(fail_fast:, outputs:, variables:)
        resolve_and_execute fail_fast: fail_fast, outputs: outputs, variables: variables

        self
      rescue ::Kitchen::TransientFailure => error
        raise ::Kitchen::TransientFailure, "Verifying the '#{self}' system failed:\n\t#{error.message}"
      end

      private

      attr_accessor :attrs, :attrs_outputs, :configuration_attributes, :hosts, :inspec_options_factory, :logger

      def execute_inspec_runner(fail_fast:)
        ::Kitchen::Terraform::InSpecFactory.new(fail_fast: fail_fast, hosts: hosts).build(
          options: inspec_options,
          profile_locations: configuration_attributes.fetch(:profile_locations),
        ).exec
      end

      def inspec_options
        inspec_options_factory.build attributes: attrs, system_configuration_attributes: configuration_attributes
      end

      def resolve(outputs:, variables:)
        ::Kitchen::Terraform::SystemAttrsInputsResolver.new(attrs: attrs).resolve inputs: variables
        ::Kitchen::Terraform::SystemHostsResolver.new(outputs: outputs).resolve(
          hosts: hosts,
          hosts_output: configuration_attributes.fetch(:hosts_output),
        ) if configuration_attributes.key? :hosts_output
        ::Kitchen::Terraform::SystemAttrsOutputsResolver.new(attrs: attrs).resolve(
          attrs_outputs: attrs_outputs,
          outputs: outputs,
        )
      rescue ::Kitchen::ClientError => error
        raise ::Kitchen::ClientError, "Verifying the '#{self}' system failed:\n\t#{error.message}"
      end

      def resolve_and_execute(fail_fast:, outputs:, variables:)
        logger.warn "Verifying the '#{self}' system..."
        resolve outputs: outputs, variables: variables
        execute_inspec_runner fail_fast: fail_fast
        logger.warn "Finished verifying the '#{self}' system."
      end
    end
  end
end
