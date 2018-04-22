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

require "kitchen/terraform/config_attribute_type"
require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_attribute_definer"
require "kitchen/terraform/config_schemas/integer"

# This module is a factory for configuration attributes of type integer.
module ::Kitchen::Terraform::ConfigAttributeType::Integer
  # This method creates a configuration attribute module to be included by a plugin class.
  #
  # @param attribute [::Symbol] the symbol corresponding to the attribute.
  # @param default_value [::Integer] the default value of the attribute.
  # @return [::Module] the configuration attribute module.
  def self.create(attribute:, default_value:)
    ::Module
      .new do
        def self.included(plugin_class)
          ::Kitchen::Terraform::ConfigAttributeDefiner
            .new(
              attribute: self,
              schema: ::Kitchen::Terraform::ConfigSchemas::Integer
            )
            .define plugin_class: plugin_class
        end
      end
      .tap do |config_attribute|
        config_attribute
          .define_singleton_method :to_sym do
            attribute
          end

        config_attribute.extend ::Kitchen::Terraform::ConfigAttributeCacher

        config_attribute
          .define_method "config_#{attribute}_default_value" do
            default_value
          end
      end
  end
end
