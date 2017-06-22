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

require "kitchen/terraform/client"
require "kitchen/terraform/client/execute_command"

# Validates the syntax of Terraform configuration files.
#
# @see https://www.terraform.io/docs/commands/validate.html Terraform validate command
module ::Kitchen::Terraform::Client::Validate
  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use to execute the validate command.
  # @param directory [::String] the directory containing files to validate.
  # @param logger [#<<] a logger to receive the stdout and stderr of the validate command.
  # @param timeout [::Integer] the maximum execution time in seconds for the validate command.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, directory:, logger:, timeout:)
    ::Kitchen::Terraform::Client::ExecuteCommand.call cli: cli, command: "validate", logger: logger, target: directory,
                                                      timeout: timeout
  end
end
