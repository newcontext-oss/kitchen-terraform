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

require_relative 'deprecated_variables_coercer'
require_relative 'simple_coercer'

module Terraform
  # A coercer for values of [:variables]
  class VariablesCoercer
    def coerce(attr:, value:)
      coercer(value: value).coerce attr: attr, value: value
    end

    private

    attr_accessor :configurable

    def coercer(value:)
      [::Array, ::String]
        .find proc { return simple_coercer }, &value.method(:is_a?)

      ::Terraform::DeprecatedVariablesCoercer.new configurable: configurable
    end

    def simple_coercer
      ::Terraform::SimpleCoercer
        .new configurable: configurable,
             expected: 'a mapping of Terraform variable assignments',
             method: method(:Hash)
    end

    def initialize(configurable:)
      self.configurable = configurable
    end
  end
end
