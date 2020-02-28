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

require "kitchen/terraform/systems_verifier/fail_fast"
require "kitchen/terraform/systems_verifier/fail_slow"

module Kitchen
  module Terraform
    # SystemsVerifierFactory is the class of objects which build SystemVerifiers.
    class SystemsVerifierFactory
      # #build creates a SystemVerifier.
      #
      # @param systems [Array<::Kitchen::Terraform::System>] the Systems to be verified.
      # @return [Kitchen::Terraform::SystemsVerifier::FailFast, ::Kitchen::Terraform::SystemsVerifier::FailSlow] a
      #   SystemsVerifier.
      def build(systems:)
        if fail_fast
          ::Kitchen::Terraform::SystemsVerifier::FailFast.new systems: systems
        else
          ::Kitchen::Terraform::SystemsVerifier::FailSlow.new systems: systems
        end
      end

      # #initialize prepares a new instance of the class.
      #
      # @param fail_fast [Boolean] a toggle to fail fast or fail slow.
      # @return [Kitchen::Terraform::SystemsVerifierFactory]
      def initialize(fail_fast:)
        self.fail_fast = fail_fast
      end

      private

      attr_accessor :fail_fast
    end
  end
end
