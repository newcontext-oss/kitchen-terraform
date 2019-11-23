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
require "kitchen/terraform/shell_out"

module Kitchen
  module Terraform
    module Command
      # Output is the class of objects which run the `terraform output` command.
      class Output
        # @option options [String] :cwd the directory in which to run the command.
        # @option options [Integer] :timeout the maximum duration in seconds to run the command.
        # @param client [String] the pathname of the Terraform client.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @param options [Hash] options which adjust the execution of the command.
        # @return [Kitchen::Terraform::Command::Output]
        def initialize(client:, logger:, options:)
          self.client = client
          self.logger = logger
          self.options = options
        end

        # Runs the command.
        #
        # @yieldparam output [Hash] the standard output of the command.
        def run
          ::Kitchen::Terraform::ShellOut.run(
            client: client,
            command: "output -json",
            logger: logger,
            options: options,
          ) do |standard_output:|
            yield outputs: ::Kitchen::Util.stringified_hash(::JSON.parse(standard_output))
          end
        rescue ::JSON::ParserError => error
          logger.error "Parsing Terraform output as JSON experienced an error:\n\t#{error.message}"

          raise ::Kitchen::TransientFailure, "Failed parsing Terraform output as JSON."
        rescue ::Kitchen::TransientFailure => error
          if /no\\ outputs\\ defined/.match ::Regexp.escape error.to_s
            logger.warn "There are no Terraform outputs defined."
            yield outputs: {}
          else
            raise error
          end
        end

        private

        attr_accessor :client, :logger, :options
      end
    end
  end
end
