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
require "kitchen/terraform/command/destroy"
require "kitchen/terraform/command/init"
require "kitchen/terraform/command/workspace_delete"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/verify_version"

module Kitchen
  module Terraform
    module Driver
      # A Test Kitchen instance is destroyed through the following steps.
      #
      # ===== Initializing the Terraform Working Directory
      #
      # {include:Kitchen::Terraform::Command::Init}
      #
      # ===== Selecting or Creating the Test Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceSelect}
      #
      # {include:Kitchen::Terraform::Command::WorkspaceNew}
      #
      # ===== Destroying the Terraform State
      #
      # {include:Kitchen::Terraform::Command::Destroy}
      #
      # ===== Selecting the Default Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceSelect}
      #
      # ===== Deleting the Test Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceDelete}
      class Destroy
        # #call executes the action.
        #
        # @raise [Kitchen::TransientFailure] if a command fails.
        # @return [self]
        def call
          verify_version.call
          execute_workflow

          self
        end

        # #initialize prepares a new instance.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @return [Kitchen::Terraform::Driver::Destroy]
        def initialize(config:, logger:, version_requirement:, workspace_name:)
          self.logger = logger
          self.options = { cwd: config.fetch(:root_module_directory) }
          self.workspace_name = workspace_name
          self.command_destroy = ::Kitchen::Terraform::Command::Destroy.new config: config, logger: logger
          self.command_init = ::Kitchen::Terraform::Command::Init.new(
            config: config.to_hash.merge(upgrade_during_init: false),
            logger: logger,
          )
          self.command_workspace_delete = ::Kitchen::Terraform::Command::WorkspaceDelete.new(
            config: config,
            logger: logger,
          )
          self.command_workspace_new = ::Kitchen::Terraform::Command::WorkspaceNew.new config: config, logger: logger
          self.command_workspace_select = ::Kitchen::Terraform::Command::WorkspaceSelect.new(
            config: config,
            logger: logger,
          )
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new(
            config: config,
            logger: logger,
            version_requirement: version_requirement,
          )
        end

        private

        attr_accessor(
          :command_destroy,
          :command_init,
          :command_workspace_delete,
          :command_workspace_new,
          :command_workspace_select,
          :logger,
          :options,
          :verify_version,
          :workspace_name,
        )

        def execute_workflow
          command_init.run
          select_or_create_test_workspace
          command_destroy.run
          command_workspace_select.run workspace_name: "default"
          command_workspace_delete.run workspace_name: workspace_name
        end

        def select_or_create_test_workspace
          command_workspace_select.run workspace_name: workspace_name
        rescue ::Kitchen::TransientFailure
          command_workspace_new.run workspace_name: workspace_name
        end
      end
    end
  end
end
