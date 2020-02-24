# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "etc"
require "kitchen"
require "mixlib/shellout"

module Kitchen
  module Terraform
    # Terraform commands are run by shelling out and using the
    # {https://www.terraform.io/docs/commands/index.html command-line interface}. The shell out environment includes the
    # TF_IN_AUTOMATION environment variable as specified by the
    # {https://www.terraform.io/guides/running-terraform-in-automation.html#controlling-terraform-output-in-automation Running Terraform in Automation guide}.
    class ShellOut
      # #initialize prepares a new instance of the class.
      #
      # @param command [String] the command to run.
      # @param logger [Kitchen::Logger] a logger for logging messages.
      # @return [Kitchen::Terraform::CommandExecutor]
      def initialize(command:, logger:, options:)
        self.command = command
        self.logger = logger
        self.shell_out = ::Mixlib::ShellOut.new(
          command,
          options.merge(
            environment: { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true", "TF_WARN_OUTPUT_ERRORS" => "1" },
            live_stream: logger,
          )
        )
      end

      # #run executes a command.
      #
      # @yieldparam standard_output [String] the standard output of the command.
      # @raise [Kitchen::TransientFailure] if running the command results in failure.
      # @return [self]
      def run
        execute_workflow

        yield standard_output: shell_out.stdout

        self
      end

      private

      attr_accessor :command, :logger, :shell_out

      def error_access_message
        "Running the command `#{command}` failed due to unauthorized access to the Terraform client. Authorize the " \
        "#{::Etc.getlogin} user to execute the client to avoid this error."
      end

      def error_no_entry_message
        "Running the command `#{command}` failed due to a nonexistent Terraform client. Set `driver.client` to the " \
        "pathname of a client to avoid this error."
      end

      def error_non_zero_message
        "Running the command `#{command}` failed due to a non-zero exit code of #{shell_out.exitstatus}."
      end

      def error_timeout_message
        "Running the command `#{command}` failed due to an excessive execution time. Increase " \
        "`driver.command_timeout` to avoid this error."
      end

      def execute_workflow
        logger.debug run_start_message
        run_command
        logger.debug run_finish_message
        verify_exit_code
      end

      def run_command
        shell_out.run_command
      rescue ::Errno::EACCES
        raise ::Kitchen::TransientFailure, error_access_message
      rescue ::Errno::ENOENT
        raise ::Kitchen::TransientFailure, error_no_entry_message
      rescue ::Mixlib::ShellOut::CommandTimeout
        raise ::Kitchen::TransientFailure, error_timeout_message
      end

      def run_finish_message
        "Finished running command `#{command}` in #{shell_out.execution_time} seconds."
      end

      def run_start_message
        "Running command `#{command}` in directory #{shell_out.cwd} with a timeout of #{shell_out.timeout} seconds..."
      end

      def verify_exit_code
        shell_out.error!
      rescue ::Mixlib::ShellOut::ShellCommandFailed
        raise ::Kitchen::TransientFailure, error_non_zero_message
      end
    end
  end
end
