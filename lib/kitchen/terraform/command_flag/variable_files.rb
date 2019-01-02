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
require "shellwords"

module Kitchen
  module Terraform
    module CommandFlag
      # VariableFiles provides logic to handle the `-var-file` flag.
      class VariableFiles
        def to_s
          @variable_files.inject @command.to_s do |command, variable_file|
            command.concat " -var-file=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit variable_file}\""
          end
        end

        private

        def initialize(command:, variable_files:)
          @command = command
          @variable_files = variable_files
        end
      end
    end
  end
end
