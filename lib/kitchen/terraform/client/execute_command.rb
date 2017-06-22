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
require "kitchen/terraform/client/process_options"
require "mixlib/shellout"

# Executes Terraform commands.
#
# @see https://www.terraform.io/docs/commands/index.html Terraform commands
module ::Kitchen::Terraform::Client::ExecuteCommand
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Try::Mixin

  # Invokes the function.
  #
  # @param cli [::String] the path of the Terraform CLI to use for command execution.
  # @param command [::String] the name of the command to execute.
  # @param logger [#<<] a logger to receive the stdout and stderr of the command.
  # @param options [::Hash] the options for the command.
  # @param target [::String] the target of the command.
  # @param timeout [::Integer] the maximum execution time in seconds for the command.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(cli:, command:, logger:, options: {}, target: "", timeout:)
    ::Kitchen::Terraform::Client::ProcessOptions.call(unprocessed_options: options).fmap do |processed_options|
      ::Mixlib::ShellOut.new [cli, command, *processed_options, target].join(" ").strip,
                             live_stream: logger, timeout: timeout
    end.bind do |shell_out|
      Try ::Errno::EACCES, ::Errno::ENOENT, ::Mixlib::ShellOut::CommandTimeout do
        shell_out.run_command
      end
    end.bind do |shell_out|
      Try ::Mixlib::ShellOut::ShellCommandFailed do
        shell_out.error!
        shell_out
      end
    end.to_either.fmap(&:stdout).or do |error|
      Left "`#{cli} #{command} #{target}` failed: '#{error}'"
    end
  end
end
