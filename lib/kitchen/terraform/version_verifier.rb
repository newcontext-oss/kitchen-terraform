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

require "kitchen/terraform/version_verifier_strategy_factory"

module Kitchen
  module Terraform
    # VersionVerifier is the class of objects which verify a Terraform client version against a requirement.
    class VersionVerifier
      # #verify verifies a version against the requirement.
      #
      # @param version [Gem::Version] the Terraform client version.
      # @raise [Kitchen::TransientFailure] if running the command fails.
      # @raise [Kitchen::UserError] if the version is unsupported.
      # @return [self]
      def verify(version:)
        version_verifier_strategy_factory.build(version: version).call

        self
      end

      # #initialize prepares an instance of the class.
      #
      # @param version_requirement [Gem::Requirement] the requirement for version support.
      # @return [Kitchen::Terraform::VersionVerifier]
      def initialize(version_requirement:)
        self.version_verifier_strategy_factory = ::Kitchen::Terraform::VersionVerifierStrategyFactory.new(
          version_requirement: version_requirement
        )
      end

      private

      attr_accessor :version_verifier_strategy_factory
    end
  end
end
