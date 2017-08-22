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

require "dry-validation"
require "kitchen"
require "kitchen/terraform"
require "kitchen/terraform/define_config_attribute"

# Defines a hash of strings configuration attribute for a plugin class.
#
# @see http://dry-rb.org/gems/dry-validation/ DRY Validation
module ::Kitchen::Terraform::DefineHashOfStringsConfigAttribute
  # Invokes the function.
  #
  # @param attribute [::Symbol] the name of the attribute.
  # @param plugin_class [::Class] the plugin class on which the attribute will be defined.
  def self.call(attribute:, plugin_class:)
    ::Kitchen::Terraform::DefineConfigAttribute.call(
      attribute: attribute,
      initialize_default_value: lambda do |_|
        {}
      end,
      plugin_class: plugin_class,
      schema: lambda do
        configure do
          def self.messages
            super.merge en: {
              errors: {
                keys_are_strings_or_symbols?: "keys must be strings or symbols",
                values_are_strings?: "values must be strings"
              }
            }
          end

          def keys_are_strings_or_symbols?(hash)
            hash.keys.all? do |key|
              key.is_a?(::String) | key.is_a?(::Symbol)
            end
          end

          def values_are_strings?(hash)
            hash.values.all? do |value|
              value.is_a? ::String
            end
          end
        end
        required(:value).value(
          :hash?,
          :keys_are_strings_or_symbols?,
          :values_are_strings?
        )
      end
    )
  end
end
