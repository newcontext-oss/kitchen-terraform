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
require "kitchen/terraform/client/options/destroy"
require "kitchen/terraform/client/options/input"
require "kitchen/terraform/client/options/no_color"
require "kitchen/terraform/client/options/out"
require "kitchen/terraform/client/options/parallelism"
require "kitchen/terraform/client/options/state"
require "kitchen/terraform/client/options/state_out"
require "kitchen/terraform/client/options/update"
require "kitchen/terraform/client/options/var"
require "kitchen/terraform/client/options/var_file"
require "kitchen/terraform/client/validate"
require "kitchen/terraform/create_directories"

# Creates the directories to contain the root Terraform module, the Terraform execution plan, and the Terraform state,
# then validates the Terraform configuration, updates any Terraform dependencies, and applies a constructive or
# destructive Terraform execution plan to the Terraform state.
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
  # @see ::Kitchen::Terraform::CreateDirectories
  def self.call(config:, destroy: false, logger:)
    ::Kitchen::Terraform::CreateDirectories.call(
      directories: [
        config.fetch(:directory),
        ::File.dirname(config.fetch(:plan)),
        ::File.dirname(config.fetch(:state))
      ]
    ).fmap do |created_directories|
      logger.debug created_directories
    end.bind do
      ::Kitchen::Terraform::Client::Validate.call cli: config.fetch(:cli),
                                                  directory: config.fetch(:directory),
                                                  logger: logger,
                                                  timeout: config.fetch(:command_timeout)
    end.bind do
      ::Kitchen::Terraform::Client::Get.call cli: config.fetch(:cli),
                                             logger: logger,
                                             options: [
                                               ::Kitchen::Terraform::Client::Options::Update.new,
                                             ],
                                             root_module: config.fetch(:directory),
                                             timeout: config.fetch(:command_timeout)
    end.bind do
      ::Kitchen::Terraform::Client::Plan.call(
        cli: config.fetch(:cli),
        logger: logger,
        options: [
          (::Kitchen::Terraform::Client::Options::Destroy.new if destroy),
          ::Kitchen::Terraform::Client::Options::Input.new(value: false),
          (::Kitchen::Terraform::Client::Options::NoColor.new if not config.fetch(:color)),
          ::Kitchen::Terraform::Client::Options::Out.new(value: config.fetch(:plan)),
          ::Kitchen::Terraform::Client::Options::Parallelism.new(value: config.fetch(:parallelism)),
          ::Kitchen::Terraform::Client::Options::State.new(value: config.fetch(:state)),
          *config.fetch(:variables).map do |name, value|
            ::Kitchen::Terraform::Client::Options::Var.new name: name, value: value
          end,
          *config.fetch(:variable_files).map do |value|
            ::Kitchen::Terraform::Client::Options::VarFile.new value: value
          end,
        ],
        root_module: config.fetch(:directory),
        timeout: config.fetch(:command_timeout)
      )
    end.bind do
      ::Kitchen::Terraform::Client::Apply.call(
        cli: config.fetch(:cli),
        logger: logger,
        options: [
          ::Kitchen::Terraform::Client::Options::Input.new(value: false),
          (::Kitchen::Terraform::Client::Options::NoColor.new if not config.fetch(:color)),
          ::Kitchen::Terraform::Client::Options::Parallelism.new(value: config.fetch(:parallelism)),
          ::Kitchen::Terraform::Client::Options::StateOut.new(value: config.fetch(:state)),
        ],
        plan: config.fetch(:plan),
        timeout: config.fetch(:command_timeout)
      )
    end.fmap do
      "driver workflow was a success"
    end.or do |error|
      Left "driver workflow was a failure\n#{error}"
    end
  end
end
