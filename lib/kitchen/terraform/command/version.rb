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
require "rubygems"

module Kitchen
  module Terraform
    module Command
      # Version is the class of objects which represent the <tt>terraform version</tt> command.
      class Version < ::Gem::Version
        # #run executes the command.
        #
        # @yieldparam version [Gem::Version] the Terraform client version.
        # @return [self]
        # @raise [Kitchen::TransientFailure] if running the command results in failure.
        def run
          ::Kitchen::Terraform::ShellOut.run(
            client: client,
            command: "version",
            logger: logger,
            options: {},
          ) do |standard_output:|
            yield version: ::Gem::Version.new(standard_output.slice(/Terraform v(\d+\.\d+\.\d+)/, 1))
          end
        rescue => error
          logger.error error.message

          raise ::Kitchen::TransientFailure, "Running command `terraform version` resulted in failure."
        end

        # @param client [String] the pathname of the Terraform client.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @return [Kitchen::Terraform::Command::Version]
        def initialize(client:, logger:)
          self.client = client
          self.logger = logger
        end

        private

        attr_accessor :client, :logger
      end
    end
  end
end
