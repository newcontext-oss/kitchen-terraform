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
    module VerifyVersionRescueStrategy
      # Permissive is the class of objects which provide a permissive rescue strategy to handle a failure to verify the
      # Terraform client version.
      class Permissive
        # #call warns the user that the version is unsupported.
        #
        # @return [self]
        def call
          logger.warn message

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @return [Kitchen::Terraform::VerifyVersionRescueStrategy::Permissive]
        def initialize(logger:)
          self.logger = logger
          self.message = "Verifying the Terraform client version failed. Set `driver.verify_version: true` to " \
                         "upgrade this warning to an error."
        end

        private

        attr_accessor :logger, :message
      end
    end
  end
end
