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

require "kitchen/terraform/version_verifier_strategy/permissive"
require "kitchen/terraform/version_verifier_strategy/strict"

module Kitchen
  module Terraform
    # VersionVerifier is the class of objects which verify a Terraform client version against a requirement.
    class VersionVerifier
      class << self
        # .permissive creates a permissive VersionVerifier.
        def permissive(logger:, requirement:)
          new(
            logger: logger,
            requirement: requirement,
            strategy: ::Kitchen::Terraform::VersionVerifierStrategy::Permissive.new(logger: logger),
          )
        end

        # .strict creates a strict VersionVerifier.
        def strict(logger:, requirement:)
          new(
            logger: logger,
            requirement: requirement,
            strategy: ::Kitchen::Terraform::VersionVerifierStrategy::Strict.new(logger: logger),
          )
        end
      end

      # #verify verifies a version against the requirement.
      def verify(version:)
        @logger.info "Supported Terraform client versions are in the interval of #{@requirement}."
        if @requirement.satisfied_by? version
          @strategy.supported
        else
          @strategy.unsupported
        end
      end

      private

      def initialize(logger:, requirement:, strategy:)
        @logger = logger
        @requirement = requirement
        @strategy = strategy
      end
    end
  end
end
