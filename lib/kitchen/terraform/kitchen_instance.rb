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

require "kitchen/terraform"
require "kitchen/terraform/breaking/kitchen_instance"
require "kitchen/terraform/deprecating/kitchen_instance"
require "kitchen/terraform/version"

module ::Kitchen::Terraform::KitchenInstance
  def self.new(kitchen_instance:, version: ::Kitchen::Terraform::Version.new)
    case version
    when ::Kitchen::Terraform::Breaking::KitchenInstance
      ::Kitchen::Terraform::Breaking::KitchenInstance.new kitchen_instance
    when ::Kitchen::Terraform::Deprecating::KitchenInstance
      ::Kitchen::Terraform::Deprecating::KitchenInstance.new kitchen_instance
    end
  end
end
