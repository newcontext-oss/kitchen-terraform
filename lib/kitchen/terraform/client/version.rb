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
require "kitchen/terraform/client"
require "kitchen/terraform/client/execute_command"

# Retrieves the version of the Terraform Command-Line Interface (CLI).
#
# @see https://www.terraform.io/docs/commands/index.html Terraform commands
module ::Kitchen::Terraform::Client::Version
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Maybe::Mixin

  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use to execute the version command.
  # @param logger [#<<] a logger to receive the stdout and stderr of the version command.
  # @param timeout [::Integer] the time in seconds to wait for the version command to finish.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, logger:, timeout:)
    ::Kitchen::Terraform::Client::ExecuteCommand
      .call(cli: cli, command: "version", logger: logger, timeout: timeout)
      .bind do |output|
        Maybe output.slice /v(\d+\.\d+)/, 1
      end.bind do |major_minor_versions|
        Right Float major_minor_versions
      end.or do |error|
        error.nil? and Left "Terraform client version output did not match 'vX.Y'" or Left error
      end.or do |error|
        Left "Unable to parse Terraform client version output\n#{error}"
      end
  end
end
