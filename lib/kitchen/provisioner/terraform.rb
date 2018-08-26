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
require "kitchen/terraform/configurable"
require "kitchen/terraform/error"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Provisioner
module ::Kitchen::Provisioner
end

# The provisioner utilizes the driver to apply changes to the Terraform state in order to reach the desired
# configuration of the root module.
#
# === Commands
#
# The following command-line actions are provided by the provisioner.
#
# ==== kitchen converge
#
# A Test Kitchen instance is converged through the following steps.
#
# ===== Selecting the Test Terraform Workspace
#
#   terraform workspace select kitchen-terraform-<instance>
#
# ===== Updating the Terraform Dependency Modules
#
#   terraform get -update <directory>
#
# ===== Validating the Terraform Root Module
#
#   terraform validate \
#     -check-variables=true \
#     [-no-color] \
#     [-var=<variables.first>...] \
#     [-var-file=<variable_files.first>...] \
#     <directory>
#
# ===== Applying the Terraform State Changes
#
#   terraform apply\
#     -lock=<lock> \
#     -lock-timeout=<lock_timeout>s \
#     -input=false \
#     -auto-approve=true \
#     [-no-color] \
#     -parallelism=<parallelism> \
#     -refresh=true \
#     [-var=<variables.first>...] \
#     [-var-file=<variable_files.first>...] \
#     <directory>
#
# ===== Retrieving the Terraform Output
#
#   terraform output -json
#
# ==== kitchen doctor
#
# Checks the system and the Kitchen configuration for common errors.
#
# ===== Describing the command
#
#   kitchen help doctor
#
# ===== Checking for errors
#
#   kitchen doctor
#
# === Configuration Attributes
#
# The provisioner has no configuration attributes, but the +provisioner+ mapping must be declared with the plugin name
# within the {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}.
#
#   provisioner:
#     name: terraform
#
# @example Describe the converge command
#   kitchen help converge
# @example Converge a Test Kitchen instance
#   kitchen converge default-ubuntu
# @version 2
class ::Kitchen::Provisioner::Terraform < ::Kitchen::Provisioner::Base
  kitchen_provisioner_api_version 2

  include ::Kitchen::Terraform::Configurable

  # Converges a Test Kitchen instance.
  #
  # @param state [::Hash] the mutable instance and provisioner state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  def call(state)
    instance
      .driver
      .apply do |output:|
        state
          .store(
            :kitchen_terraform_outputs,
            output
          )
      end
  rescue ::Kitchen::Terraform::Error => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end
end
