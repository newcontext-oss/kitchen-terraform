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

require "dry/logic"
require "kitchen/terraform"

# {http://dry-rb.org/gems/dry-validation/custom-predicates/ DRY Validation custom predicates}.
#
# @abstract It must be extended by a schema in order to be used.
module ::Kitchen::Terraform::ConfigPredicates
  include ::Dry::Logic::Predicates

  predicate :hash_of_symbols_and_strings? do |value|
    value.kind_of? ::Hash and
      all_symbols? keys: value.keys and
      all_strings? values: value.values
  end

  # A callback to define predicates on a configuration schema which is invoked when this module is extended by said
  # configuration schema.
  #
  # @param config_schema [::Kitchen::Terraform::ConfigSchema] a configuration schema.
  # @return [self]
  def self.extended(config_schema)
    config_schema.predicates self
    self
  end

  private_class_method

  # If all keys are symbols then the result is +true+; else the result is +false+.
  #
  # @api private
  # @param keys [::Enumerable] keys that must be only symbols
  # @return [::TrueClass, ::FalseClass] the result
  def self.all_symbols?(keys:)
    keys
      .all? do |key|
        key.kind_of? ::Symbol
      end
  end

  # If all values are strings then the result is +true+; else the result is +false+.
  #
  # @api private
  # @param values [::Enumerable] values that must be only strings
  # @return [::TrueClass, ::FalseClass] the result
  def self.all_strings?(values:)
    values
      .all? do |value|
        value.kind_of? ::String
      end
  end

  private

  def messages
    super
      .merge(
        en:
          {
            errors:
              {
                hash_of_symbols_and_strings?: "must be a hash which includes only symbol keys and string values",
              }
          }
      )
  end
end
