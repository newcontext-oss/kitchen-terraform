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
require "kitchen/terraform"
require "kitchen/terraform"
require "mixlib/shellout"

# This module comprises behaviour to run a Terraform command using the command line interface.
#
# @see https://www.terraform.io/docs/commands/index.html Terraform Commands (CLI)
module ::Kitchen::Terraform::ShellOut
  extend ::Dry::Monads::Either::Mixin
  extend ::Dry::Monads::Try::Mixin

  # Runs a Terraform command.
  #
  # @param command [::String] the command to run.
  # @param duration [::Integer] the maximum duration in seconds to run the command.
  # @param logger [::Kitchen::Logger] a Test Kitchen logger to capture the output from running the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see https://rubygems.org/gems/mixlib-shellout mixlib-shellout
  def self.run(command:, duration: ::Mixlib::ShellOut::DEFAULT_READ_TIMEOUT, logger:)
    Try ::Mixlib::ShellOut::InvalidCommandOption do
      ::Mixlib::ShellOut
        .new(
          "terraform #{command}",
          environment: {"TF_IN_AUTOMATION" => "true"},
          live_stream: logger,
          timeout: duration
        )
    end
      .bind do |shell_out|
        Try(
          ::Errno::EACCES,
          ::Errno::ENOENT,
          ::Mixlib::ShellOut::CommandTimeout,
          ::Mixlib::ShellOut::ShellCommandFailed
        ) do
          logger.warn "Running command `#{shell_out.command}`"
          shell_out.run_command
          shell_out.error!
          shell_out.stdout
        end
      end
      .to_either
      .or do |error|
        Left "Running command resulted in failure: #{error}"
      end
  end
end
