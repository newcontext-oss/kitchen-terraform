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

require "kitchen"
require "terraform/configurable"

# The design of the provisioner is unconventional compared to other Test Kitchen provisioner plugins. Since Terraform
# creates and provisions resources when applying an execution plan, managed by the driver, the provisioner simply
# proxies the driver's create action to apply any changes to the existing Terraform state.
#
# === Configuration
#
# ==== Example .kitchen.yml snippet
#
#   provisioner:
#     name: terraform
#
# @see ::Kitchen::Driver::Terraform
# @see https://www.terraform.io/docs/commands/plan.html Terraform execution plan
# @see https://www.terraform.io/docs/state/index.html Terraform state
# @version 2
class ::Kitchen::Provisioner::Terraform < ::Kitchen::Provisioner::Base
  kitchen_provisioner_api_version 2

  include ::Terraform::Configurable

  # Proxies the driver's create action.
  #
  # @example
  #   `kitchen converge suite-name`
  # @param state [::Hash] the mutable instance and provisioner state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  def call(state)
    instance.driver.create state
  end
end
