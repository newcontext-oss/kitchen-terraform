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
      class << self
        # .run executes a Terraform command.
        #
        # @param client [String] the pathname of the Terraform client.
        # @param command [String] the command to run.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @param options [Hash] options which adjust the execution of the command.
        # @option options [Integer] :timeout the maximum duration in seconds to run the command.
        # @option options [String] :cwd the directory in which to run the command.
        # @raise [Kitchen::TransientFailure] if running the command fails.
        # @return [self]
        # @see https://rubygems.org/gems/mixlib-shellout mixlib-shellout
        # @yieldparam standard_output [String] the standard output from running the command.
        def run(client:, command:, logger:, options:, &block)
          block ||= lambda do |standard_output:|
          end

          new(client: client, command: command, logger: logger, options: options).run(&block)

          self
        end
      end

      # @param client [String] the pathname of the Terraform client.
      # @param command [String] the command to run.
      # @param logger [Kitchen::Logger] a logger for logging messages.
      # @param options [Hash] options which adjust the execution of the command.
      # @option options [Integer] :timeout the maximum duration in seconds to run the command.
      # @option options [String] :cwd the directory in which to run the command.
      # @return [Kitchen::Terraform::ShellOut]
      def initialize(client:, command:, logger:, options:)
        self.logger = logger
        self.shell_out = ::Mixlib::ShellOut.new "#{client} #{command}", options.merge(
          cwd: options.fetch(:cwd) do
            ::Dir.pwd
          end,
          environment: { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true", "TF_WARN_OUTPUT_ERRORS" => "1" },
          live_stream: logger,
        )
        self.command = shell_out.command
        self.timeout = shell_out.timeout
      end

      def run
        logger.warn(
          "Running command `#{command}` in directory #{shell_out.cwd} with a timeout of #{timeout} seconds."
        )

        shell_out.run_command
        if shell_out.error?
          logger.warn "Running command `#{command}` returned a non-zero exit code #{shell_out.exitstatus}."

          raise ::Kitchen::TransientFailure, "Failed running command `#{command}`:\n\t#{shell_out.stderr}"
        end

        yield standard_output: shell_out.stdout
      rescue ::Errno::EACCES
        logger.error "Running command `#{command}` experienced an error due to unauthorized access to a file or directory."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`."
      rescue ::Errno::ENOENT
        logger.error "Running command `#{command}` experienced an error due to a nonexistent file or directory."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`."
      rescue ::Mixlib::ShellOut::CommandTimeout
        logger.error "Running command `#{command}` experienced an error due to the execution time exceeding the timeout of #{timeout} seconds."

        raise ::Kitchen::TransientFailure, "Failed running command `#{command}`."
      end

      private

      attr_accessor :command, :logger, :shell_out, :timeout
    end
  end
end
