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

require "kitchen/terraform/command_executor"

module Kitchen
  module Terraform
    module Command
      # The workspace is selected by running a command like the following example:
      #   terraform workspace select <name>
      class WorkspaceSelect
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @option config [String] :client the pathname of the Terraform client.
        # @option config [Integer] :command_timeout the the number of seconds to wait for the command to finish running.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root
        #   Terraform module.
        # @return [Kitchen::Terraform::Command::WorkspaceSelect]
        def initialize(config:, logger:)
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.options = { cwd: config.fetch(:root_module_directory), timeout: config.fetch(:command_timeout) }
        end

        # #run executes the command.
        #
        # @param workspace_name [String] the name of the Terraform workspace to select.
        # @return [self]
        # @raise [Kitchen::TransientFailure] if the result of executing the command is a failure.
        def run(workspace_name:)
          command_executor.run(
            command: "workspace select #{workspace_name}",
            options: options,
          )

          self
        end

        private

        attr_accessor :command_executor, :options
      end
    end
  end
end
