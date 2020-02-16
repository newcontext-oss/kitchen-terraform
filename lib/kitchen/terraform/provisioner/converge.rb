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
require "kitchen/terraform/command/apply"
require "kitchen/terraform/command/get"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/validate"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/debug_logger"
require "kitchen/terraform/outputs_manager"
require "kitchen/terraform/variables_manager"
require "kitchen/terraform/verify_version"

module Kitchen
  module Terraform
    module Provisioner
      # A Test Kitchen instance is converged through the following steps.
      #
      # ===== Selecting the Test Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceSelect}
      #
      # ===== Updating the Terraform Dependency Modules
      #
      # {include:Kitchen::Terraform::Command::Get}
      #
      # ===== Validating the Terraform Root Module
      #
      # {include:Kitchen::Terraform::Command::Validate}
      #
      # ===== Applying the Terraform State Changes
      #
      # {include:Kitchen::Terraform::Command::Apply}
      #
      # ===== Retrieving the Terraform Output
      #
      # {include:Kitchen::Terraform::Command::Output}
      class Converge
        # #call executes the action.
        #
        # @param state [Hash] the Kitchen instance state.
        # @raise [Kitchen::TransientFailure] if a command fails.
        # @return [self]
        def call(state:)
          verify_version.call
          execute_workflow
          save_variables_and_outputs state: state

          self
        end

        # #initialize prepares a new instance.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @return [Kitchen::Terraform::Driver::Converge]
        def initialize(config:, logger:, version_requirement:, workspace_name:)
          self.logger = logger
          self.options = { cwd: config.fetch(:root_module_directory) }
          self.workspace_name = workspace_name
          self.command_apply = ::Kitchen::Terraform::Command::Apply.new config: config, logger: logger
          self.command_get = ::Kitchen::Terraform::Command::Get.new config: config, logger: logger
          self.command_output = ::Kitchen::Terraform::Command::Output.new(
            config: config,
            logger: ::Kitchen::Terraform::DebugLogger.new(logger),
          )
          self.command_validate = ::Kitchen::Terraform::Command::Validate.new config: config, logger: logger
          self.command_workspace_select = ::Kitchen::Terraform::Command::WorkspaceSelect.new(
            config: config,
            logger: logger,
          )
          self.outputs_manager = ::Kitchen::Terraform::OutputsManager.new logger: logger
          self.variables = config.fetch :variables
          self.variables_manager = ::Kitchen::Terraform::VariablesManager.new logger: logger
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new(
            config: config,
            logger: logger,
            version_requirement: version_requirement,
          )
        end

        private

        attr_accessor(
          :command_apply,
          :command_get,
          :command_output,
          :command_validate,
          :command_workspace_select,
          :logger,
          :options,
          :outputs_manager,
          :variables,
          :variables_manager,
          :verify_version,
          :workspace_name,
        )

        def execute_workflow
          command_workspace_select.run workspace_name: workspace_name
          command_get.run
          command_validate.run
          command_apply.run
        end

        def save_variables_and_outputs(state:)
          command_output.run do |outputs:|
            outputs_manager.save outputs: outputs, state: state
          end
          variables_manager.save variables: variables, state: state
        end
      end
    end
  end
end
