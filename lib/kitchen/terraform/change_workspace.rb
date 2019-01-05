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

require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"

module Kitchen
  module Terraform
    # This module is a function which handles the selection or creation of a Terraform workspace.
    module ChangeWorkspace
      class << self
        # This method executes the function.
        #
        # @param directory [::String] the directory in which to run the commands.
        # @param name [::String] the name of the workspace to select or create.
        # @param timeout [::Integer] the maximum duration in seconds to run the commands.
        # @raise [::Kitchen::Terraform::Error] if the result of running both commands is a failure.
        # @return [self]
        def call(directory:, name:, timeout:)
          ::Kitchen::Terraform::Command::WorkspaceSelect.run(
            directory: directory,
            name: name,
            timeout: timeout,
          )

          self
        rescue ::Kitchen::Terraform::Error
          ::Kitchen::Terraform::Command::WorkspaceNew.run(
            directory: directory,
            name: name,
            timeout: timeout,
          )

          self
        end
      end
    end
  end
end
