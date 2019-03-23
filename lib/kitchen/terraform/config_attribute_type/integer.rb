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
require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_attribute_type"

# This module applies the behaviour of a configuration attribute of type integer to a module which must be included by a
# plugin class.
#
# @see http://dry-rb.org/gems/dry-validation/basics/working-with-schemas/ DRY Validation Working With Schemas
module ::Kitchen::Terraform::ConfigAttributeType::Integer
  # This method applies the configuration attribute behaviour to a module.
  #
  # @param attribute [::Symbol] the symbol corresponding to the configuration attribute.
  # @param config_attribute [::Module] a module.
  # @param default_value [::Proc] a proc which returns the default value.
  # @return [self]
  def self.apply(attribute:, config_attribute:, default_value:)
    ::Kitchen::Terraform::ConfigAttribute
      .new(
        attribute: attribute,
        default_value: default_value,
        schema: ::Dry::Validation
          .Schema do
          required(:value).filled :int?
        end,
      ).apply config_attribute: config_attribute

    self
  end
end
