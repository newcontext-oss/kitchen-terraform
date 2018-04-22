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
require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_attribute_definer"

# This module is a factory for configuration attributes.
module ::Kitchen::Terraform::ConfigAttribute
  # This method creates a configuration attribute module to be included by a plugin class.
  #
  # @param attribute [::Symbol] the symbol corresponding to the attribute.
  # @param default_value [::Object] the default value of the attribute.
  # @return [::Module] the configuration attribute module.
  def self.create(attribute:, default_value:, schema:)
    ::Module
      .new
      .tap do |config_attribute|
        config_attribute
          .define_singleton_method :included do |plugin_class|
            ::Kitchen::Terraform::ConfigAttributeDefiner
              .new(
                attribute: self,
                schema: schema
              )
              .define plugin_class: plugin_class
          end

        config_attribute
          .define_singleton_method :to_sym do
            attribute
          end

        config_attribute.extend ::Kitchen::Terraform::ConfigAttributeCacher

        config_attribute
          .send(
            :define_method,
            "config_#{attribute}_default_value"
          ) do
            default_value
          end
      end
  end
end
