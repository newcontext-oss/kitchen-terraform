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
  # @param working_directory [::String] the directory in which to run the command.
  # @raise [::Kitchen::Terraform::Error] if running the command fails.
  # @return [::String] the standard output from running the command.
  # @see https://rubygems.org/gems/mixlib-shellout mixlib-shellout
  # @yieldparam standard_output [::String] the standard output from running the command.
  def self.run(command:, duration: ::Mixlib::ShellOut::DEFAULT_READ_TIMEOUT, logger:, working_directory:, &block)
    block ||=
      lambda do |standard_output:|
        standard_output
      end

    run_shell_out(
      command: command,
      duration: duration,
      logger: logger,
      working_directory: working_directory,
      &block
    )
  rescue ::Errno::EACCES,
         ::Errno::ENOENT,
         ::Mixlib::ShellOut::InvalidCommandOption,
         ::Mixlib::ShellOut::CommandTimeout,
         ::Mixlib::ShellOut::ShellCommandFailed => error
    handle error: error
  end

  private_class_method

  # @api private
  def self.handle(error:)
    raise(
      ::Kitchen::Terraform::Error,
      "Running command resulted in failure: #{error.message}"
    )
  end

  # @api private
  def self.run_shell_out(command:, duration:, logger:, working_directory:)
    yield(
      standard_output:
        ::Mixlib::ShellOut
          .new(
            "terraform #{command}",
            cwd: working_directory,
            environment: {"TF_IN_AUTOMATION" => "true"},
            live_stream: logger,
            timeout: duration
          )
          .tap do |shell_out|
            logger.warn "Running command `#{shell_out.command}` in directory #{working_directory}"
            shell_out.run_command
            shell_out.error!
          end
          .stdout
    )
  end
end
