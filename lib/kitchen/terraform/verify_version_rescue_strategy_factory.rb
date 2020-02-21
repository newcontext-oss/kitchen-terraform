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

require "kitchen/terraform/verify_version_rescue_strategy/permissive"
require "kitchen/terraform/verify_version_rescue_strategy/strict"

module Kitchen
  module Terraform
    # VerifyVersionRescueStrategyFactory is the class of objects which build rescue strategies for instances of
    # VerifyVersion.
    class VerifyVersionRescueStrategyFactory
      # #build creates a strategy.
      #
      # @param logger [Kitchen::Logger] a logger to log messages.
      # @return [Kitchen::Terraform::VerifyVersionRescueStrategy::Strict,
      #   Kitchen::Terraform::VerifyVersionRescueStrategy::Permissive]
      def build(logger:)
        if verify_version
          ::Kitchen::Terraform::VerifyVersionRescueStrategy::Strict.new
        else
          ::Kitchen::Terraform::VerifyVersionRescueStrategy::Permissive.new logger: logger
        end
      end

      # @param verify_version [Boolean] a toggle for a strict strategy or a permissive strategy.
      # @return [Kitchen::Terraform::VerifyVersionRescueStrategyFactory]
      def initialize(verify_version:)
        self.verify_version = verify_version
      end

      private

      attr_accessor :verify_version
    end
  end
end
