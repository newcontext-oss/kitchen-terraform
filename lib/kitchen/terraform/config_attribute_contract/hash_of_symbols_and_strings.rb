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

require "dry/validation"

module Kitchen
  module Terraform
    module ConfigAttributeContract
      # HashOfSymbolsAndStrings is the class of objects that provide a configuration attribute contract for a hash
      # including only symbol keys and string values.
      class HashOfSymbolsAndStrings < ::Dry::Validation::Contract
        schema do
          required(:value).hash
        end

        rule :value do
          value.each_pair do |symbol, string|
            if ::Symbol != symbol.class
              key.failure "the key of the key-value pair '#{symbol} => #{string}' must be a scalar"
            elsif ::String != string.class
              key.failure "the value of the key-value pair '#{symbol} => #{string}' must be a scalar"
            end
          end
        end
      end
    end
  end
end