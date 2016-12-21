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
  # Behaviour for the [:parallelism] config option
  module ParallelismConfig
    def self.included(configurable_class)
      configurable_class
        .required_config :parallelism do |_, value, configurable|
          configurable.coerce_parallelism value: value
        end
      configurable_class.default_config :parallelism, 10
    end

    def coerce_parallelism(value:)
      config[:parallelism] = Integer value
    rescue ::ArgumentError, ::TypeError
      config_error attribute: 'parallelism', expected: 'an integer'
    end
  end
end
