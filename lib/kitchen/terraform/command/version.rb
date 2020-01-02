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
require "kitchen/terraform/command_executor"
require "rubygems"

module Kitchen
  module Terraform
    module Command
      # Version is the class of objects which represent the <tt>terraform version</tt> command.
      class Version
        # #run executes the command.
        #
        # @param options [Hash] options which adjust the execution of the command.
        # @option options [Integer] :timeout the maximum duration in seconds to run the command.
        # @option options [String] :cwd the directory in which to run the command.
        # @yieldparam version [Gem::Version] the Terraform client version.
        # @return [self]
        # @raise [Kitchen::TransientFailure] if running the command results in failure.
        def run(options:)
          command_executor.run(
            command: "version",
            options: options,
          ) do |standard_output:|
            yield version: ::Gem::Version.new(standard_output.slice(/Terraform v(\d+\.\d+\.\d+)/, 1))
          end
        rescue => error
          logger.error error.message

          raise ::Kitchen::TransientFailure, "Running the version command resulted in failure."
        end

        # @param client [String] the pathname of the Terraform client.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @return [Kitchen::Terraform::Command::Version]
        def initialize(client:, logger:)
          self.logger = logger
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new client: client, logger: logger
        end

        private

        attr_accessor :command_executor, :logger
      end
    end
  end
end
