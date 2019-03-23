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
require "kitchen/terraform/config_predicates"

# Behaviour to provide a configuration attribute predicate for a hash including only symbol keys and string values.
#
# This module must be declared as providing predicates and extended in a schema's configuration in order to be used.
#
# @see http://dry-rb.org/gems/dry-validation/custom-predicates/ DRY Logic Custom Predicates
module ::Kitchen::Terraform::ConfigPredicates::HashOfSymbolsAndStrings
  # A callback to configure an extending schema with this predicate.
  #
  # @param schema [::Dry::Validation::Schema] the schema to be configured.
  # @return [self]
  def self.extended(schema)
    schema.predicates self
    self
  end

  include ::Dry::Logic::Predicates

  predicate :hash_of_symbols_and_strings? do |value|
    value.kind_of? ::Hash and
      all_symbols? keys: value.keys and
      all_strings? values: value.values
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
        en: {
          errors: {
            hash_of_symbols_and_strings?: "must be a hash which includes only symbol keys and string values",
          },
        },
      )
  end
end
