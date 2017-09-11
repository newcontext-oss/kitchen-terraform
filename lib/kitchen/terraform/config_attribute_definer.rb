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

require "kitchen/terraform"

# Defines a configuration attribute on a plugin class.
class ::Kitchen::Terraform::ConfigAttributeDefiner
  # Defines the configuration attribute on a plugin class.
  #
  # @param plugin_class [::Kitchen::Terraform::ConfigAttributeVerifier] A plugin class which has configuration
  #   attribute verification behaviour.
  # @return [void]
  def define(plugin_class:)
    plugin_class
      .verify_config(
        attribute: @symbol,
        schema: @schema
      )
    plugin_class
      .default_config @symbol do |plugin|
        @attribute.default_value plugin: plugin
      end
  end

  private

  # Initializes a definer.
  #
  # @api private
  # @param attribute [::Kitchen::Terraform::ConfigAttribute] an attribute to be defined on a plugin class.
  # @param schema [::Dry::Validation::Schema] a schema to use for validation of values of the attribute.
  def initialize(attribute:, schema:)
    @attribute = attribute
    @schema = schema
    @symbol = attribute.to_sym
  end
end
