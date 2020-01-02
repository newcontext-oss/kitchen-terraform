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
require "kitchen/terraform/shell_out"

module Kitchen
  module Terraform
    # CommandExecutor is the class of objects which execute Terraform CLI commands.
    class CommandExecutor
      # @param client [String] the pathname of the Terraform client.
      # @param logger [Kitchen::Logger] a logger for logging messages.
      # @return [Kitchen::Terraform::CommandExecutor]
      def initialize(client:, logger:)
        self.client = client
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
      def run(command:, options:, &block)
        block ||= ::Proc.new do |standard_output:|
        end

        ::Kitchen::Terraform::ShellOut.new(client: client, command: command, logger: logger, options: options)
          .run do |standard_output:|
          block.call standard_output: standard_output
        end

        self
      end

      private

      attr_accessor :client, :logger
    end
  end
end
