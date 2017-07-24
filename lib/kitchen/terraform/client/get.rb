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

# Downloads and updates modules mentioned in the root Terraform module.
#
# @see https://www.terraform.io/docs/commands/get.html Terraform get command
module ::Kitchen::Terraform::Client::Get
  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use to execute the get command.
  # @param logger [#<<] a logger to receive the stdour and stderr of the get command.
  # @param root_module [::String] the path of the root module.
  # @param timeout [::Integer] the maximum execution time in seconds for the get command.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, logger:, options:, root_module:, timeout:)
    ::Kitchen::Terraform::Client::ExecuteCommand.call cli: cli,
                                                      command: "get",
                                                      logger: logger,
                                                      options: options,
                                                      target: root_module,
                                                      timeout: timeout
  end
end
