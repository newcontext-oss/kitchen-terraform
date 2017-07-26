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

# Initializes a Terraform configuration.
#
# @see https://www.terraform.io/docs/commands/init.html Terraform init command
module ::Kitchen::Terraform::Client::Init
  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use to execute the init command.
  # @param logger [#<<] a logger to receive the stdout and stderr of the init command.
  # @param module_path [::String] the path of the downloaded Terraform module.
  # @param module_source [::String] the source of the Terraform module to download.
  # @param options [::Array] the options for the init command.
  # @param timeout [::Integer] the maximum execution time in seconds for the plan command.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, logger:, module_path:, module_source:, options:, timeout:)
    ::Kitchen::Terraform::Client::ExecuteCommand.call cli: cli,
                                                      command: "init",
                                                      logger: logger,
                                                      options: options,
                                                      target: "#{module_source} #{module_path}",
                                                      timeout: timeout
  end
end
