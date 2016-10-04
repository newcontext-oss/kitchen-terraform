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

module Terraform
  # Behaviour for the [:variables] config option
  module VariablesConfig
    def self.included(configurable_class)
      configurable_class.required_config :variables do |_, value, configurable|
        configurable.coerce_variables value: value
      end
      configurable_class.default_config :variables, {}
    end

    def coerce_variables(value:)
      config[:variables] =
        if value.is_a?(Array) || value.is_a?(String)
          deprecated_variables_format value: value
        else
          Hash value
        end
    rescue ArgumentError, TypeError
      config_error attribute: 'variables',
                   expected: 'a mapping of Terraform variable assignments'
    end

    private

    def deprecated_variables_format(value:)
      config_deprecated attribute: 'variables', remediation: 'Use a mapping',
                        type: 'a list or string', version: '1.0'
      Hash[Array(value).map { |string| string.split '=' }]
    end
  end
end
