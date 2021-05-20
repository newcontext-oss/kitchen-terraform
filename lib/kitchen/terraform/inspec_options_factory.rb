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

require "inspec"
require "kitchen/terraform/system_bastion_host_resolver"
require "kitchen/terraform/system_inspec_map"
require "rubygems"

module Kitchen
  module Terraform
    # InSpecOptionsMapper is the class of objects which build Inspec options.
    class InSpecOptionsFactory
      class << self
        # #inputs_key provides a key for InSpec profile inputs which depends on the version of InSpec.
        #
        # @return [Symbol] if the version is less than 4.3.2, :attributes; else, :inputs.
        def inputs_key
          if ::Gem::Requirement.new("< 4.3.2").satisfied_by? ::Gem::Version.new ::Inspec::VERSION
            :attributes
          else
            :inputs
          end
        end
      end

      # #build creates a mapping of InSpec options. Most key-value pairs are derived from the configuration attributes
      # of a system; some key-value pairs are hard-coded.
      #
      # @param attributes [Hash] the attributes to be added to the InSpec options.
      # @param system_configuration_attributes [Hash] the configuration attributes of a system.
      # @raise [Kitchen::ClientError] if the system bastion host fails to be resolved.
      # @return [Hash] a mapping of InSpec options.
      def build(attributes:, system_configuration_attributes:)
        map_system_to_inspec system_configuration_attributes: system_configuration_attributes
        options.store self.class.inputs_key, attributes
        resolve_bastion_host system_configuration_attributes: system_configuration_attributes

        options
      end

      # #initialize prepares a new instance of the class.
      #
      # @param outputs [Hash] the Terraform output variables.
      # @return [Kitchen::Terraform::InSpecOptionsFactory]
      def initialize(outputs:)
        self.options = { "distinct_exit" => false }
        self.system_bastion_host_resolver = ::Kitchen::Terraform::SystemBastionHostResolver.new outputs: outputs
        self.system_inspec_map = ::Kitchen::Terraform::SYSTEM_INSPEC_MAP.dup
      end

      private

      attr_accessor :options, :system_bastion_host_resolver, :system_inspec_map

      def map_system_to_inspec(system_configuration_attributes:)
        system_configuration_attributes.lazy.select do |attribute_name, _|
          system_inspec_map.key?(attribute_name)
        end.each do |attribute_name, attribute_value|
          options.store system_inspec_map.fetch(attribute_name), attribute_value
        end
      end

      def resolve_bastion_host(system_configuration_attributes:)
        system_bastion_host_resolver.resolve(
          bastion_host: system_configuration_attributes.fetch(:bastion_host, ""),
          bastion_host_output: system_configuration_attributes.fetch(:bastion_host_output, ""),
        ) do |bastion_host:|
          options.store :bastion_host, bastion_host
        end
      end
    end
  end
end
