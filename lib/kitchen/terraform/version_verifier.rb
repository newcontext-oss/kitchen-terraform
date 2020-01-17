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
      # @param options [Hash] options which adjust the execution of the command.
      # @option options [Integer] :timeout the maximum duration in seconds to run the command.
      # @option options [String] :cwd the directory in which to run the command.
      # @param requirement [Gem::Requirement] the requirement for version support.
      # @param strict [Boolean] the toggle of strict or permissive verification.
      # @return [self]
      def verify(options:, requirement:, strict:)
        run_and_invoke_strategy options: options, requirement: requirement, strict: strict
        logger.banner "Finished verification of the Terraform client version."

        self
      rescue ::Kitchen::TransientFailure => error
        handle error: error
      end

      # @param command [Kitchen::Terraform::Command::Version] a version command.
      # @param logger [Kitchen::Logger] a logger to log messages.
      # @return [Kitchen::Terraform::VersionVerifier]
      def initialize(command:, logger:)
        self.command = command
        self.logger = logger
      end

      private

      attr_accessor :command, :logger

      def handle(error:)
        logger.error error.message

        raise ::Kitchen::TransientFailure, "Failed verification of the Terraform client version."
      end

      def run_and_invoke_strategy(options:, requirement:, strict:)
        logger.banner "Starting verification of the Terraform client version."
        logger.warn "Supported Terraform client versions are in the interval of #{requirement}."
        command.run options: options do |version:|
          ::Kitchen::Terraform::VersionVerifierStrategyFactory.new(requirement: requirement, strict: strict).build(
            logger: logger,
            version: version,
          ).call
        end
      end
    end
  end
end
