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
        # @param systems [Array<::Kitchen::Terraform::System>] a list of systems to be verified.
        # @return [Kitchen::Terraform::SystemsVerifier::FailSlow]
        def initialize(systems:)
          self.messages = []
          self.systems = systems
        end

        # #verify verifies each system.
        #
        # @param outputs [Hash] a mapping of Terraform outputs.
        # @param variables [Hash] a mapping of Terraform variables.
        # @raise [Kitchen::TransientFailure] if verification of a system fails.
        # @return [self]
        def verify(outputs:, variables:)
          systems.each do |system|
            verify_and_continue outputs: outputs, system: system, variables: variables
          end

          raise ::Kitchen::TransientFailure, messages.join("\n\n") if !messages.empty?

          self
        end

        private

        attr_accessor :messages, :systems

        def verify_and_continue(outputs:, system:, variables:)
          system.verify fail_fast: false, outputs: outputs, variables: variables
        rescue ::Kitchen::TransientFailure => error
          messages.push error.message
        end
      end
    end
  end
end
