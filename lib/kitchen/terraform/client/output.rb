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

require "dry/monads"
require "json"
require "kitchen/terraform/client"
require "kitchen/terraform/client/execute_command"

# Extracts the values of Terraform output variables from a Terraform state.
#
# @see https://www.terraform.io/docs/commands/output.html Terraform output command
# @see https://www.terraform.io/docs/configuration/outputs.html Terraform output variables
# @see https://www.terraform.io/docs/state/index.html Terraform state
module ::Kitchen::Terraform::Client::Output
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Try::Mixin

  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use to execute the output command.
  # @param logger [#<<] a logger to receive the stdout and stderr of the output command.
  # @param options [::Hash] the options for the output command.
  # @param timeout [::Integer] the maximum execution time in seconds for the output command.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, logger:, options:, timeout:)
    ::Kitchen::Terraform::Client::ExecuteCommand
      .call(cli: cli, command: "output", logger: logger, options: options.merge(json: true), timeout: timeout)
      .bind do |output|
        Try ::JSON::ParserError do
          ::JSON.parse output
        end
      end.to_either.or do |error|
        Left "parsing Terraform client output as JSON failed\n#{error}"
      end
  end
end
