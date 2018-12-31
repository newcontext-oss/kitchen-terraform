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

require "kitchen/terraform/shell_out_nu"

module Kitchen
  module Terraform
    module Command
      # WorkspaceDelete is the class of objects which represent the <tt>terraform workspace delete</tt> command.
      class WorkspaceDelete
        class << self
          # Initializes an instance by running `terraform workspace delete`.
          #
          # @param directory [::String] the directory in which to run the command.
          # @param name [::String] the name of the workspace to select.
          # @param timeout [::Integer] the maximum duration in seconds to run the command.
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [self]
          # @yieldparam workspace_delete [::Kitchen::Terraform::Command::WorkspaceDelete] an instance initialized with
          #   the output of the command.
          def run(directory:, name:, timeout:)
            new(name: name).tap do |workspace_delete|
              ::Kitchen::Terraform::ShellOutNu.run(
                command: workspace_delete,
                directory: directory,
                timeout: timeout,
              )
              yield workspace_delete: workspace_delete
            end

            self
          end
        end

        def ==(workspace_delete)
          to_s == workspace_delete.to_s
        end

        def store(output:)
          @output = String output

          self
        end

        def to_s
          "terraform workspace delete #{@name}"
        end

        private

        def initialize(name:)
          @name = name
        end
      end
    end
  end
end
