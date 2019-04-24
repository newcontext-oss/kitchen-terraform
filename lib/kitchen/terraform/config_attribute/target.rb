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

require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_attribute_type/string"

# This attribute controls a target resource for terraform to manage
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example:: <code>target: module.alb</code>
module ::Kitchen::Terraform::ConfigAttribute::Target
  ::Kitchen::Terraform::ConfigAttributeType::String
    .apply(
      attribute: :target,
      config_attribute: self,
      default_value: lambda do
        nil
      end,
    )
end
