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
    module VersionVerifierStrategy
      # UnsupportedPermissive is the class of objects which provide a permissive strategy for unsupported Terraform
      # client versions.
      class UnsupportedPermissive
        # #call informs the user that the version is unsupported.
        #
        # @return [self]
        def call
          logger.warn(
            "The Terraform client version is not supported. Set `driver.verify_version: true` to upgrade this " \
            "warning to an error."
          )

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @return [Kitchen::Terraform::VersionVerifierStrategy::UnsupportedPermissive]
        def initialize(logger:)
          self.logger = logger
        end

        private

        attr_accessor :logger
      end
    end
  end
end
