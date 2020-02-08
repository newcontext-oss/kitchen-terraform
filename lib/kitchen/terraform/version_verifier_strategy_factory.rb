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

require "kitchen/terraform/version_verifier_strategy/supported"
require "kitchen/terraform/version_verifier_strategy/unsupported"

module Kitchen
  module Terraform
    # VersionVerifierStrategyFactory is the class of objects which build strategies for instances of VersionVerifier.
    class VersionVerifierStrategyFactory
      # #build creates a strategy.
      #
      # @param version [Gem::Version] the Terraform client version.
      # @return [Kitchen::Terraform::VersionVerifierStrategy::Supported,
      #   Kitchen::Terraform::VersionVerifierStrategy::Unsupported]
      def build(version:)
        if version_requirement.satisfied_by? version
          return ::Kitchen::Terraform::VersionVerifierStrategy::Supported.new
        else
          return ::Kitchen::Terraform::VersionVerifierStrategy::Unsupported.new
        end
      end

      # @param version_requirement [Gem::Requirement] the requirement for version support.
      # @return [Kitchen::Terraform::VersionVerifierStrategyFactory]
      def initialize(version_requirement:)
        self.version_requirement = version_requirement
      end

      private

      attr_accessor :version_requirement
    end
  end
end
