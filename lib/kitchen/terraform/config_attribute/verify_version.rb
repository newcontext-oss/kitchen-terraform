# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
      # This attribute toggles strict or permissive verification of support for the version of the Terraform client specified by the
      # <code>client</code> attribute.
      #
      # Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
      # Required:: False
      # Default:: </code>true</code>
      # Example:: <code>verify_version: false</code>
      module VerifyVersion
        ::Kitchen::Terraform::ConfigAttribute.new(
          attribute: :verify_version,
          default_value: lambda do
            true
          end,
          schema: ::Kitchen::Terraform::ConfigSchemas::Boolean,
        ).apply config_attribute: self
      end
    end
  end
end
