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
require "kitchen/terraform/version_verifier_strategy/unsupported_permissive"
require "kitchen/terraform/version_verifier_strategy/unsupported_strict"

module Kitchen
  module Terraform
    # VersionVerifierStrategyFactory is the class of objects which build strict strategies.
    class VersionVerifierStrategyFactory
      # #build creates a strict strategy for a supported Terraform client version or an unsupported Terraform
      # client version.
      #
      # @param logger [Kitchen::Logger] a logger to log messages.
      # @param version [Gem::Version] the Terraform client version.
      # @return [Kitchen::Terraform::VersionVerifierStrategy::Supported,
      #   Kitchen::Terraform::VersionVerifierStrategy::Unsupported,
      #   Kitchen::Terraform::VersionVerifierStrategy::Unsupported]
      def build(logger:, version:)
        if requirement.satisfied_by? version
          return ::Kitchen::Terraform::VersionVerifierStrategy::Supported.new logger: logger
        elsif strict
          return ::Kitchen::Terraform::VersionVerifierStrategy::UnsupportedStrict.new logger: logger
        else
          return ::Kitchen::Terraform::VersionVerifierStrategy::UnsupportedPermissive.new logger: logger
        end
      end

      # @param requirement [Gem::Requirement] the requirement for version support.
      # @param strict [Boolean] the toggle of strict or permissive verification.
      # @return [Kitchen::Terraform::VersionVerifierStrategyFactory]
      def initialize(requirement:, strict:)
        self.requirement = requirement
        self.strict = strict
      end

      private

      attr_accessor :requirement, :strict
    end
  end
end
