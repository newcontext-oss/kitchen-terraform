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

# This class applies the behaviour of a configuration attribute to a module which must be included by a plugin class.
class ::Kitchen::Terraform::ConfigAttribute
  # This method applies the configuration attribute behaviour to a module.
  #
  # @param config_attribute [::Module] a module.
  # @return [self]
  def apply(config_attribute:)
    self.config_attribute = config_attribute
    define_singleton_included
    define_singleton_to_sym
    define_config_attribute_default_value
    self
  end

  private

  attr_accessor(
    :attribute,
    :config_attribute,
    :default_value,
    :schema
  )

  # @api private
  def define_config_attribute_default_value
    config_attribute
      .send(
        :define_method,
        "config_#{attribute}_default_value",
        &default_value
      )
  end

  # @api private
  def define_singleton_included
    local_schema = schema

    config_attribute
      .define_singleton_method :included do |plugin_class|
        ::Kitchen::Terraform::ConfigAttributeDefiner
          .new(
            attribute: self,
            schema: local_schema
          )
          .define plugin_class: plugin_class
      end
  end

  # @api private
  def define_singleton_to_sym
    local_attribute = attribute

    config_attribute
      .define_singleton_method :to_sym do
        local_attribute
      end

    config_attribute.extend ::Kitchen::Terraform::ConfigAttributeCacher
  end

  # @api private
  def initialize(attribute:, default_value:, schema:)
    self.attribute = attribute
    self.default_value = default_value
    self.schema = schema
  end
end
