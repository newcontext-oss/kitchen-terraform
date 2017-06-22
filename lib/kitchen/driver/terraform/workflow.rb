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
require "kitchen/driver/terraform"
require "kitchen/terraform/client/apply"
require "kitchen/terraform/client/get"
require "kitchen/terraform/client/validate"

# Validates Terraform configuration, updates Terraform dependencies, and applies a constructive or destructive Terraform
# execution plan to a Terraform state.
module ::Kitchen::Driver::Terraform::Workflow
  extend ::Dry::Monads::Either::Mixin

  # Invokes the function.
  #
  # @param config [::Kitchen::Config] the configuration of the kitchen-terraform driver.
  # @param destroy [::TrueClass, ::FalseClass] the flag that controls constructive or destructive planning.
  # @param logger [#<<] a logger to receive the execution output of the Terraform Client functions.
  # @return [::Dry::Monads::Either] the result of the function.
  # @see ::Kitchen::Terraform::Client::Apply
  # @see ::Kitchen::Terraform::Client::Get
  # @see ::Kitchen::Terraform::Client::Plan
  # @see ::Kitchen::Terraform::Client::Validate
  def self.call(config:, destroy: false, logger:)
    ::Kitchen::Terraform::Client::Validate.call(
      cli: config.fetch(:cli), directory: config.fetch(:directory), logger: logger,
      timeout: config.fetch(:command_timeout)
    ).bind do
      ::Kitchen::Terraform::Client::Get.call cli: config.fetch(:cli), logger: logger,
                                             root_module: config.fetch(:directory),
                                             timeout: config.fetch(:command_timeout)
    end.bind do
      ::Kitchen::Terraform::Client::Plan.call cli: config.fetch(:cli),
                                              logger: logger, options: {
                                                color: config.fetch(:color), destroy: destroy, out: config.fetch(:plan),
                                                parallelism: config.fetch(:parallelism), state: config.fetch(:state),
                                                var: config.fetch(:variables), var_file: config.fetch(:variable_files)
                                              }, root_module: config.fetch(:directory),
                                              timeout: config.fetch(:command_timeout)
    end.bind do
      ::Kitchen::Terraform::Client::Apply.call cli: config.fetch(:cli), logger: logger,
                                               options: {
                                                 color: config.fetch(:color), parallelism: config.fetch(:parallelism),
                                                 state_out: config.fetch(:state)
                                               }, plan: config.fetch(:plan), timeout: config.fetch(:command_timeout)
    end.fmap do
      "driver workflow was a success"
    end.or do |error|
      Left "driver workflow was a failure\n#{error}"
    end
  end
end
