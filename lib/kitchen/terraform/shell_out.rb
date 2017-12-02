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

require "kitchen/terraform"
require "kitchen/terraform/error"
require "mixlib/shellout"

# Terraform commands are run by shelling out and using the
# {https://www.terraform.io/docs/commands/index.html command-line interface}, which is assumed to be present in the
# {https://en.wikipedia.org/wiki/PATH_(variable) PATH} of the user. The shell out environment includes the
# TF_IN_AUTOMATION environment variable as specified by the
# {https://www.terraform.io/guides/running-terraform-in-automation.html#controlling-terraform-output-in-automation Running Terraform in Automation guide}.
module ::Kitchen::Terraform::ShellOut
  # Runs a Terraform command.
  #
  # @param command [::String] the command to run.
  # @param duration [::Integer] the maximum duration in seconds to run the command.
  # @param logger [::Kitchen::Logger] a Test Kitchen logger to capture the output from running the command.
  # @raise [::Kitchen::Terraform::Error] if running the command fails.
  # @return [::String] the standard output from running the command.
  # @see https://rubygems.org/gems/mixlib-shellout mixlib-shellout
  def self.run(command:, duration: ::Mixlib::ShellOut::DEFAULT_READ_TIMEOUT, logger:)
    ::Mixlib::ShellOut
      .new(
        "terraform #{command}",
        environment: {"TF_IN_AUTOMATION" => "true"},
        live_stream: logger,
        timeout: duration
      )
      .tap do |shell_out|
        logger.warn "Running command `#{shell_out.command}`"
        shell_out.run_command
        shell_out.error!
      end
      .stdout
  rescue ::Errno::EACCES,
         ::Errno::ENOENT,
         ::Mixlib::ShellOut::InvalidCommandOption,
         ::Mixlib::ShellOut::CommandTimeout,
         ::Mixlib::ShellOut::ShellCommandFailed => error
    raise(
      ::Kitchen::Terraform::Error,
      "Running command resulted in failure: #{error.message}"
    )
  end
end
