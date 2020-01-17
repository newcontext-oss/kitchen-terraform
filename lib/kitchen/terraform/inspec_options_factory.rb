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

require "inspec"
require "kitchen/terraform/system_inspec_map"
require "rubygems"

module Kitchen
  module Terraform
    # InSpecOptionsMapper is the class of objects which build Inspec options.
    class InSpecOptionsFactory
      class << self
        # #inputs_key provides a key for InSpec profile inputs which depends on the version of InSpec.
        #
        # @return [::Symbol] if the version is less than 4.3.2, :attributes; else, :inputs.
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
      # @param attributes [::Hash] the attributes to be added to the InSpec options.
      # @param system_configuration_attributes [::Hash] the configuration attributes of a system.
      # @return [::Hash] a mapping of InSpec options.
      def build(attributes:, system_configuration_attributes:)
        system_configuration_attributes.lazy.select do |attribute_name, _|
          system_inspec_map.key?(attribute_name)
        end.each do |attribute_name, attribute_value|
          options.store system_inspec_map.fetch(attribute_name), attribute_value
        end

        options.merge self.class.inputs_key => attributes
      end

      private

      attr_accessor :options, :system_inspec_map

      # @api private
      def initialize
        self.options = { "distinct_exit" => false }
        self.system_inspec_map = ::Kitchen::Terraform::SYSTEM_INSPEC_MAP.dup
      end
    end
  end
end
