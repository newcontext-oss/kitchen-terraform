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

require 'terraform/pathname_coercer'
require 'terraform/simple_config'

module Terraform
  # Behaviour for the [:plan] and [:state] config options
  module FileConfigs
    include ::Terraform::SimpleConfig

    def self.extended(configurable_class)
      %i(plan state).each do |attr|
        configurable_class.configure_required(
          attr: attr, coercer_class: ::Terraform::PathnameCoercer,
          default_value: lambda do |configurable|
            configurable.instance_pathname filename: "terraform.tf#{attr}"
          end
        )
      end
    end
  end
end
