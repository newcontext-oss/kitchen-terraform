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

require "kitchen"
require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_schemas/boolean"

module Kitchen
  module Terraform
    class ConfigAttribute
      # This attribute toggles fail fast behaviour when verifying systems.
      #
      # If fail fast behaviour is enabled then Kitchen will halt on the first error raised by a system during
      # verification; else errors raised by systems will be queued until all systems have attempted verification.
      #
      # Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
      # Required:: False
      # Default:: <code>true</code>
      # Example:: <code>fail_fast: false</code>
      module FailFast
        ::Kitchen::Terraform::ConfigAttribute.new(
          attribute: :fail_fast,
          default_value: lambda do
            true
          end,
          schema: ::Kitchen::Terraform::ConfigSchemas::Boolean,
        ).apply config_attribute: self
      end
    end
  end
end
