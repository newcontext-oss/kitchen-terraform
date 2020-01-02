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

require "kitchen"
require "mixlib/shellout"

module Kitchen
  module Terraform
    # Terraform commands are run by shelling out and using the
    # {https://www.terraform.io/docs/commands/index.html command-line interface}, which is assumed to be present in the
    # {https://en.wikipedia.org/wiki/PATH_(variable) PATH} of the user. The shell out environment includes the
    # TF_IN_AUTOMATION environment variable as specified by the
    # {https://www.terraform.io/guides/running-terraform-in-automation.html#controlling-terraform-output-in-automation Running Terraform in Automation guide}.
    class ShellOut
      # @param client [String] the pathname of the Terraform client.
      # @param command [String] the command to run.
      # @param logger [Kitchen::Logger] a logger for logging messages.
      # @return [Kitchen::Terraform::CommandExecutor]
      def initialize(client:, command:, logger:, options:)
        self.shell_out = ::Mixlib::ShellOut.new(
          "#{client} #{command}",
          options.merge(
            environment: { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true", "TF_WARN_OUTPUT_ERRORS" => "1" }, live_stream: logger,
          )
        )
        self.command = shell_out.command
        self.logger = logger
      end

      # #run executes a client command.
      #
      # @param command [String] the command to run.
      # @param options [Hash] options which adjust the execution of the command.
      # @option options [Integer] :timeout the maximum duration in seconds to run the command.
      # @option options [String] :cwd the directory in which to run the command.
      # @yieldparam standard_output [String] the standard output of the command.
      # @raise [Kitchen::TransientFailure] if running the command results in failure.
      # @return [self]
      def run()
        execute
        handle_shell_out_error if shell_out.error?

        yield standard_output: shell_out.stdout

        self
      end

      private

      attr_accessor :command, :logger, :shell_out

      def execute
        logger.warn "Running command `#{command}` in directory #{shell_out.cwd} with a timeout of #{shell_out.timeout} seconds."
        shell_out.run_command
      rescue ::Errno::EACCES
        rescue_no_access
      rescue ::Errno::ENOENT
        rescue_no_entry
      rescue ::Mixlib::ShellOut::CommandTimeout
        rescue_timeout
      end

      def handle_shell_out_error
        logger.warn "Running command `#{command}` returned a non-zero exit code #{shell_out.exitstatus}."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`:\n\t#{shell_out.stderr}"
      end

      def rescue_no_access
        logger.error "Running command `#{command}` experienced an error due to unauthorized access to a file or directory."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`."
      end

      def rescue_no_entry
        logger.error "Running command `#{command}` experienced an error due to a nonexistent file or directory."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`."
      end

      def rescue_timeout
        logger.error "Running command `#{command}` experienced an error due to the execution time exceeding the timeout."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`."
      end
    end
  end
end
