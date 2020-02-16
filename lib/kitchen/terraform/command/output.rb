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

require "json"
require "kitchen"
require "kitchen/terraform/command_executor"

module Kitchen
  module Terraform
    module Command
      # The outputs are retrieved by running a command like the following example:
      #   terraform output -json
      class Output
        # #initialize prepares an instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @option config [String] :client the pathname of the Terraform client.
        # @option config [Integer] :command_timeout the the number of seconds to wait for the command to finish running.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root
        #   Terraform module.
        # @return [Kitchen::Terraform::Command::Output]
        def initialize(config:, logger:)
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.logger = logger
          self.options = { cwd: config.fetch(:root_module_directory), timeout: config.fetch(:command_timeout) }
        end

        # #run executes the command.
        #
        # @yieldparam output [Hash] the standard output of the command.
        # @return [self]
        # @raise [Kitchen::TransientFailure] if the result of executing the command is a failure.
        def run(&block)
          run_command_executor(&block)
        rescue ::JSON::ParserError => error
          rescue_invalid_json error: error
        rescue ::Kitchen::TransientFailure => error
          rescue_no_outputs_defined error: error, &block
        end

        private

        attr_accessor(
          :command_executor,
          :logger,
          :options
        )

        def rescue_invalid_json(error:)
          logger.error "Parsing Terraform output as JSON experienced an error:\n\t#{error.message}"

          raise ::Kitchen::TransientFailure, "Failed parsing Terraform output as JSON."
        end

        def rescue_no_outputs_defined(error:)
          if /no\\ outputs\\ defined/.match ::Regexp.escape error.to_s
            logger.warn "There are no Terraform outputs defined."
            yield outputs: {}
          else
            raise error
          end
        end

        def run_command_executor
          command_executor.run(command: "output -json", options: options) do |standard_output:|
            yield outputs: ::JSON.parse(standard_output)
          end
        end
      end
    end
  end
end
