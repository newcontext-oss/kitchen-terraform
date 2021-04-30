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
require "kitchen/terraform/unsupported_client_version_error"
require "kitchen/terraform/verify_version_rescue_strategy_factory"
require "kitchen/terraform/version_verifier"
require "rubygems"

module Kitchen
  module Terraform
    # VerifyVersion is the class of objects which verify the version of the Terraform client against a version
    # requirement.
    class VerifyVersion
      # #call invokes the verification.
      #
      # @param version [Gem::Version] the Terraform client version.
      # @raise [Kitchen::ActionFailed] if the verification fails.
      # @return [self]
      def call(version:)
        logger.warn start_message
        version_verifier.verify version: version
        logger.warn finish_message
      rescue ::Kitchen::Terraform::UnsupportedClientVersionError
        rescue_strategy.call

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param config [Hash] the configuration of the driver.
      # @param logger [Kitchen::Logger] a logger for logging messages.
      # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
      # @option config [Boolean] :verify_version a toggle of strict or permissive verification of support for the
      #   version of the Terraform client.
      # @return [Kitchen::Terraform::VerifyVersion]
      def initialize(config:, logger:, version_requirement:)
        self.finish_message = "Finished verifying the Terraform client version."
        self.logger = logger
        self.rescue_strategy = ::Kitchen::Terraform::VerifyVersionRescueStrategyFactory.new(
          verify_version: config.fetch(:verify_version),
        ).build logger: logger
        self.start_message = "Verifying the Terraform client version is in the supported interval of " \
                             "#{version_requirement}..."
        self.version_verifier = ::Kitchen::Terraform::VersionVerifier.new version_requirement: version_requirement
      end

      private

      attr_accessor(
        :finish_message,
        :logger,
        :rescue_strategy,
        :start_message,
        :version_verifier
      )
    end
  end
end
