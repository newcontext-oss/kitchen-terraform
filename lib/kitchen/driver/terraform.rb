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

require "dry/monads"
require "kitchen"
require "kitchen/terraform/client/output"
require "kitchen/terraform/client/plan"
require "kitchen/terraform/client/version"
require "kitchen/terraform/define_config_attribute"
require "terraform/configurable"

# The kitchen-terraform driver is the bridge between Test Kitchen and Terraform. It manages the state of the configured
# root Terraform module by invoking its workflow in a constructive or destructive manner.
#
# === Configuration
#
# ==== Example .kitchen.yml snippet
#
#   driver:
#     name: terraform
#     command_timeout: 1000
#     cli: /usr/local/bin/terraform
#     color: false
#     directory: /directory/containing/terraform/configuration
#     parallelism: 2
#     plan: /terraform/plan
#     state: /terraform/state
#     variable_files:
#       - /first/terraform/variable/file
#       - /second/terraform/variable/file
#     variables:
#       variable_name: variable_value
#
# ==== Attributes
#
# ===== cli
#
# Description:: The path of the Terraform CLI to use for command execution.
#
# Type:: String
#
# Status:: Optional
#
# Default:: +"terraform"+
#
# ===== command_timeout
#
# Description:: The number of seconds to wait for the Terraform CLI commands to finish.
#
# Type:: Integer
#
# Status:: Optional
#
# Default:: +600+
#
# ===== color
#
# Description:: Toggle to enable or disable colored output from the Terraform CLI commands.
#
# Type:: Boolean
#
# Status:: Optional
#
# Default:: +true+
#
# ===== directory
#
# Description:: The path of the directory containing the root Terraform module to be tested.
#
# Type:: String
#
# Status:: Optional
#
# Default:: The working directory of the Test Kitchen process.
#
# ===== parallelism
#
# Description:: The maximum number of concurrent operations to allow while walking the resource graph for the Terraform
#               CLI apply and plan commands.
# Type:: Integer
#
# Status:: Optional
#
# Default:: +10+
#
# ===== plan
#
# Description:: The path of the Terraform execution plan that will be generated and applied.
#
# Type:: String
#
# Status:: Optional
#
# Default:: A descendant of the working directory of the Test Kitchen process:
#           +".kitchen/kitchen-terraform/<suite_name>/terraform.tfplan"+
#
# ===== state
#
# Description:: The path of the Terraform state that will be generated and managed.
#
# Type:: String
#
# Status:: Optional
#
# Default:: A descendant of the working directory of the Test Kitchen process:i
#           +".kitchen/kitchen-terraform/<suite_name>/terraform.tfstate"+.
#
# ===== variable_files
#
# Description:: A collection of paths of Terraform variable files to be evaluated during the creation of the Terraform
#               execution plan.
#
# Type:: Array
#
# Status:: Optional
#
# Default:: +[]+
#
# ===== variables
#
# Description:: A mapping of Terraform variable names and values to be overridden during the creation of the Terraform
#               execution plan.
#
# Type:: Hash
#
# Status:: Optional
#
# Default:: +{}+
#
# @see ::Kitchen::Driver::Terraform::Workflow
# @see https://en.wikipedia.org/wiki/Working_directory Working directory
# @see https://www.terraform.io/docs/commands/plan.html Terraform execution plan
# @see https://www.terraform.io/docs/configuration/variables.html Terraform variables
# @see https://www.terraform.io/docs/internals/graph.html Terraform resource graph
# @see https://www.terraform.io/docs/state/index.html Terraform state
# @version 2
class ::Kitchen::Driver::Terraform < ::Kitchen::Driver::Base
  kitchen_driver_api_version 2

  no_parallel_for

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :cli,
    initialize_default_value: lambda do |_plugin|
      "terraform"
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :str?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :command_timeout,
    initialize_default_value: lambda do |_plugin|
      600
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :int?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :color,
    initialize_default_value: lambda do |_plugin|
      true
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :bool?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :directory,
    initialize_default_value: lambda do |plugin|
      plugin[:kitchen_root]
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :str?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :parallelism,
    initialize_default_value: lambda do |_plugin|
      10
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :int?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :plan,
    initialize_default_value: lambda do |plugin|
      plugin.instance_pathname filename: "terraform.tfplan"
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :str?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :state,
    initialize_default_value: lambda do |plugin|
      plugin.instance_pathname filename: "terraform.tfstate"
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :str?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :variable_files,
    initialize_default_value: lambda do |_plugin|
      []
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).each :filled?, :str?
    end
  )

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :variables,
    initialize_default_value: lambda do |_plugin|
      {}
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).value :hash?
    end
  )

  include ::Terraform::Configurable

  # The driver creates the directories to contain the root module, the execution plan, and the state, then invokes its
  # workflow in a constructive manner.
  #
  # @example
  #   `kitchen create suite-name`
  # @note The user must ensure that different suites utilize separate Terraform plan and state files if they are to run
  #       the create action concurrently.
  # @param _state [::Hash] the mutable instance and driver state; this parameter is ignored.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [::Dry::Monads::Either] the result of the workflow function.
  # @see ::Kitchen::Driver::Terraform::Workflow
  def create(_state)
    self.class::CreateDirectories.call(
      directories: [config.fetch(:directory), ::File.dirname(config.fetch(:plan)), ::File.dirname(config.fetch(:state))]
    ).fmap do |created_directories|
      logger.debug created_directories
    end.bind do
      self.class::Workflow.call config: config, logger: logger
    end.or do |failure|
      raise ::Kitchen::ActionFailed, failure
    end
  end

  # The driver invokes its workflow in a destructive manner.
  #
  # @example
  #   `kitchen destroy suite-name`
  # @note The user must ensure that different suites utilize separate Terraform plan and state files if they are to run
  #       the destroy action concurrently.
  # @param _state [::Hash] the mutable instance and driver state; this parameter is ignored.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [::Dry::Monads::Either] the result of the action.
  # @see ::Kitchen::Driver::Terraform::Workflow
  def destroy(_state)
    self.class::Workflow.call(config: config, destroy: true, logger: logger).or do |failure|
      raise ::Kitchen::ActionFailed, failure
    end
  end

  # The driver proxies the client output function.
  #
  # @return [::Dry::Monads::Either] the result of the Terraform Client Output function.
  # @see ::Kitchen::Terraform::Client::Output
  def output
    ::Kitchen::Terraform::Client::Output.call cli: config.fetch(:cli), logger: debug_logger,
                                              options: {color: config.fetch(:color), state: config.fetch(:state)},
                                              timeout: config.fetch(:command_timeout)
  end

  # The driver verifies that the client version is supported.
  #
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @return [::Dry::Monads::Either] the result of the client version verification function.
  # @see ::Kitchen::Driver::Terraform::VerifyClientVersion
  # @see ::Kitchen::Terraform::Client::Version
  def verify_dependencies
    ::Kitchen::Terraform::Client::Version.call(
      cli: config.fetch(:cli), logger: debug_logger, timeout: config.fetch(:command_timeout)
    ).bind do |version|
      self.class::VerifyClientVersion.call version: version
    end.fmap do |verified_client_version|
      logger.warn verified_client_version
      verified_client_version
    end.or do |failure|
      raise ::Kitchen::UserError, failure
    end
  end
end

require "kitchen/driver/terraform/create_directories"
require "kitchen/driver/terraform/workflow"
require "kitchen/driver/terraform/verify_client_version"
