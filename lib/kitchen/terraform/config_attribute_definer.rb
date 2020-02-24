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

module Kitchen
  module Terraform
    # ConfigAttributeDefiner is the class of objects which define configuration attributes on a plugin class.
    class ConfigAttributeDefiner
      # #define defines a configuration attribute on a plugin class.
      #
      # @param plugin_class [Kitchen::Configurable] a plugin class.
      # @return [self]
      def define(plugin_class:)
        plugin_class.required_config attribute do |_attribute, value, _plugin|
          process messages: schema.call(value: value).messages, plugin_class: plugin_class
        end
        plugin_class.default_config attribute do |plugin|
          plugin.send "config_#{attribute}_default_value"
        end

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param attribute [Kitchen::Terraform::ConfigAttribute] an attribute to be defined on a plugin class.
      # @param schema [Dry::Validation::Schema] a schema to use for validation of values of the attribute.
      # @return [Kitchen::Terraform::ConfigAttributeDefined]
      def initialize(attribute:, schema:)
        self.attribute = attribute.to_sym
        self.schema = schema
      end

      private

      attr_accessor :attribute, :schema

      def process(messages:, plugin_class:)
        return if messages.empty?

        raise ::Kitchen::UserError, "#{plugin_class} configuration: #{attribute} #{messages}"
      end
    end
  end
end
