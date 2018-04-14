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

require "forwardable"
require "kitchen"
require "kitchen/terraform/configurable"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Provisioner
module ::Kitchen::Provisioner
end

# The provisioner utilizes the driver to apply changes to the Terraform state in order to reach the desired
# configuration of the root module.
#
# === Command-Line Interface
#
# The following actions are implemented by the provisioner:
#
# * {#converge kitchen converge}
#
# === Enable the Plugin
#
# The +provisioner+ mapping must be declared with the plugin name within the
# {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}.
#
#   provisioner:
#     name: terraform
#
# === Configuration
#
# The provisioner depends on the configuration of the driver. 
#
# === Running Terraform Commands
#
# {include:Kitchen::Terraform::Client}
class ::Kitchen::Provisioner::Terraform < ::Kitchen::Provisioner::Base
  extend ::Forwardable
  kitchen_provisioner_api_version 2
  include ::Kitchen::Terraform::Configurable

  def_delegators(
    :driver,
    :client,
    :color_flag,
    :color_flag,
    :lock_flag,
    :lock_timeout_flag,
    :parallelism_flag,
    :root_module_directory,
    :variable_files_flags,
    :variable_files_flags,
    :variables_flags,
    :variables_flags
  )

  # This action converges the Kitchen Instance by applying changes to the Terraform state.
  #
  # === Workflow
  #
  # ==== Selecting the Test Terraform Workspace
  #
  #   terraform workspace select kitchen-terraform-<instance>
  #
  # ==== Updating the Terraform Dependency Modules
  #
  #   terraform get -update <directory>
  #
  # ==== Validating the Terraform Root Module
  #
  #   terraform validate \
  #     -check-variables=true \
  #     [-no-color] \
  #     [-var-file=<variable_files.first>...] \
  #     [-var=<variables.first>...] \
  #     <root_module_directory>
  #
  # ==== Applying the Terraform State Changes
  #
  #   terraform apply\
  #     -auto-approve=true \
  #     -input=false \
  #     -refresh=true \
  #     -lock-timeout=<lock_timeout>s \
  #     -lock=<lock> \
  #     [-no-color] \
  #     -parallelism=<parallelism> \
  #     [-var-file=<variable_files.first>...] \
  #     [-var=<variables.first>...] \
  #     <root_module_directory>
  #
  # ==== Retrieving the Terraform Output
  #
  #   terraform output -json
  #
  # @example Describe the converge action
  #   kitchen help converge
  # @example Converge a Kitchen Instance named default-ubuntu
  #   kitchen converge default-ubuntu
  # @param kitchen_state [::Hash] the Kitchen state is manipulated by storing the Terraform output under the key
  #   +:kitchen_terraform_output+.
  # @raise [::Kitchen::ActionFailed] if the test Terraform workspace can not be selected; if the Terraform dependency 
  #   modules can not be updated; if the Terraform root module is not valid; if the Terraform state can not be changed;
  #   if the Terraform state output can not be stored in the Kitchen state.
  # @return [self]
  def call(kitchen_state)
    client.select_or_create_kitchen_instance_workspace
    client.get
    client.validate flags: validate_flags
    client.apply flags: apply_flags
    client.output container: kitchen_state
    self
  rescue ::StandardError => error
    action_failed error: error
  end

  # This method extends {::Kitchen::Terraform::Configurable#finalize_config!} to obtain the driver so that the
  # provisioner can forward calls for the Terraform client and configuration attributes.
  #
  # @param kitchen_instance [::Kitchen::Instance] the associated Kitchen Instance which is also associated with the
  #   driver.
  # @return [self]
  def finalize_config!(kitchen_instance)
    super kitchen_instance
    self.driver = kitchen_instance.driver
    self
  end

  private

  attr_accessor :driver

  # @api private
  def apply_flags
    [
      lock_timeout_flag,
      lock_flag,
      color_flag,
      parallelism_flag,
      variable_files_flags,
      variables_flags
    ]
  end

  # @api private
  def validate_flags
    [
      color_flag,
      variable_files_flags,
      variables_flags
    ]
  end
end
