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

# Creates a Terraform execution plan.
#
# @see https://www.terraform.io/docs/commands/plan.html Terraform plan command
module ::Kitchen::Terraform::Client::Plan
  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use to execute the plan command.
  # @param logger [#<<] a logger to receive the stdout and stderr of the plan command.
  # @param options [::Hash] the options for the plan command.
  # @param root_module [::String] the path of the root Terraform module.
  # @param timeout [::Integer] the maximum execution time in seconds for the plan command.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, logger:, options:, root_module:, timeout:)
    ::Kitchen::Terraform::Client::ExecuteCommand.call cli: cli,
                                                      command: "plan",
                                                      logger: logger,
                                                      options: options.merge(
                                                        input: false
                                                      ),
                                                      target: root_module,
                                                      timeout: timeout
  end
end
