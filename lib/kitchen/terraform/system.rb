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

require "kitchen/terraform/error"
require "kitchen/terraform/inspec_with_hosts"
require "kitchen/terraform/inspec_without_hosts"
require "kitchen/terraform/system_attrs_inputs_resolver"
require "kitchen/terraform/system_attrs_outputs_resolver"
require "kitchen/terraform/system_hosts_resolver"

module Kitchen
  module Terraform
    # System is the class of objects which are verified by the Terraform Verifier.
    class System
      # #each_host enumerates each host of the system.
      #
      # @yieldparam host [::String] the next host.
      # @return [self]
      def each_host
        @hosts.each do |host|
          yield host: host
        end

        self
      end

      # #verify verifies the system by executing InSpec.
      #
      # @param inputs [::Hash] the Terraform input variables to be utilized as InSpec profile attributes.
      # @param inspec_options [::Hash] the options to be passed to InSpec.
      # @param outputs [::Hash] the Terraform output variables to be utilized as InSpec profile attributes.
      # @return [self]
      def verify(inputs:, inspec_options:, outputs:)
        @logger.info "Starting verification of the '#{name}' system."
        resolve inputs: inputs, outputs: outputs do |attrs:|
          inspec.new(options: inspec_options.merge(attributes: attrs), profile_locations: @mapping.fetch(:profile_locations))
            .exec(system: self)
        end
        @logger.info "Finished verification of the '#{name}' system."

        self
      end

      private

      def initialize(logger:, mapping:)
        @attrs_outputs = mapping.fetch :attrs_outputs do
          {}
        end.dup
        @hosts = mapping.fetch :hosts do
          []
        end.dup
        @logger = logger
        @mapping = mapping
      end

      def inspec
        if @hosts.empty?
          ::Kitchen::Terraform::InSpecWithoutHosts
        else
          ::Kitchen::Terraform::InSpecWithHosts
        end
      end

      def name
        @mapping.fetch :name
      end

      def resolve(inputs:, outputs:, &block)
        resolve_hosts outputs: outputs if @mapping.key? :hosts_output
        resolve_attrs inputs: inputs, outputs: outputs, &block
      end

      def resolve_attrs(inputs:, outputs:, &block)
        ::Kitchen::Terraform::SystemAttrsInputsResolver.new(attrs: {}).resolve inputs: inputs do |attrs:|
          ::Kitchen::Terraform::SystemAttrsOutputsResolver.new(attrs: attrs, logger: @logger).resolve(attrs_outputs: @attrs_outputs, outputs: outputs, &block)
        end
      end

      def resolve_hosts(outputs:)
        ::Kitchen::Terraform::SystemHostsResolver.new(logger: @logger, outputs: outputs).resolve(
          hosts: @hosts,
          hosts_output: @mapping.fetch(:hosts_output),
        )

        self
      end
    end
  end
end
