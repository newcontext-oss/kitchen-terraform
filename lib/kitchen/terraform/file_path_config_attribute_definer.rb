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

require "kitchen/terraform/config_attribute_definer"

module Kitchen
  module Terraform
    # FilePathConfigAttributeDefiner is the class of objects which define a file path configuration attribute on a
    # plugin class.
    class FilePathConfigAttributeDefiner
      # #define defines the file path configuration attribute on a plugin class.
      #
      # @param plugin_class [Kitchen::ConfigAttributeVerifier] a plugin class which has configuration
      #   attribute verification behaviour.
      # @return [self]
      def define(plugin_class:)
        definer.define plugin_class: plugin_class
        plugin_class.expand_path_for attribute.to_sym

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param attribute [Kitchen::Terraform::ConfigAttribute] an attribute to be defined on a plugin class.
      # @param schema [Dry::Validation::Schema] a schema to use for validation of values of the attribute.
      # @return [Kitchen::Terraform::FilePathConfigAttributeDefiner]
      def initialize(attribute:, schema:)
        self.attribute = attribute
        self.definer = ::Kitchen::Terraform::ConfigAttributeDefiner.new attribute: attribute, schema: schema
      end

      private

      attr_accessor :attribute, :definer
    end
  end
end
