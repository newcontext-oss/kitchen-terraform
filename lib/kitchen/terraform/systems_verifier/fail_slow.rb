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

module Kitchen
  module Terraform
    module SystemsVerifier
      # FailSlow is the class of objects which verify systems and raise rescued errors after all systems have been
      # verified.
      class FailSlow
        # #initialize prepares a new instance of the class.
        #
        # @param logger [::Kitchen::Logger] a logger to log messages.
        # @param systems [::Array<::Kitchen::Terraform::System>] a list of systems to be verified.
        def initialize(logger:, systems:)
          self.logger = logger
          self.messages = []
          self.systems = systems
        end

        # #verify verifies each system.
        #
        # @param outputs [::Hash] a mapping of Terraform outputs.
        # @param variables [::Hash] a mapping of Terraform variables.
        # @raise [::Kitchen::TransientFailure] if verification of a system fails.
        # @return [self]
        def verify(outputs:, variables:)
          systems.each do |system|
            verify_and_continue outputs: outputs, system: system, variables: variables
          end

          raise ::Kitchen::TransientFailure, messages.join("\n\n") if !messages.empty?

          self
        end

        private

        attr_accessor :logger, :messages, :systems

        def verify_and_continue(outputs:, system:, variables:)
          system.verify fail_fast: false, outputs: outputs, variables: variables
        rescue => error
          logger.error "Verification of the '#{system}' system experienced an error:\n\t#{error.message}"
          messages.push "Failed verification of the '#{system}' system."
        end
      end
    end
  end
end
