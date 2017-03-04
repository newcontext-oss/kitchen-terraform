# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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
  # Coerces deprecated variables config
  class DeprecatedVariablesCoercer
    def coerce(attr:, value:)
      configurable.config_deprecated attr: attr, remediation: 'Use a mapping',
                                     type: 'a list or string'
      configurable[attr] =
        ::Hash[Array(value).map { |string| string.split '=' }]
    end

    private

    attr_accessor :configurable

    def initialize(configurable:)
      self.configurable = configurable
    end
  end
end
