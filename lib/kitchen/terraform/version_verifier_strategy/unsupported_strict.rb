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
      # UnsupportedStrict is the class of objects which provide a strict strategy for unsupported Terraform client
      # versions.
      class UnsupportedStrict
        # #call informs the user that the version is unsupported and fails the verification.
        #
        # @raise [Kitchen::UserError]
        # @return [void]
        def call
          logger.error(
            "The Terraform client version is not supported. Set `driver.verify_version: false` to downgrade this " \
            "error to a warning."
          )

          raise ::Kitchen::UserError, "Failed verification of the Terraform client version."
        end

        # #initialize prepares a new instance of the class.
        #
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @return [Kitchen::Terraform::VersionVerifierStrategy::UnsupportedStrict]
        def initialize(logger:)
          self.logger = logger
        end

        private

        attr_accessor :logger
      end
    end
  end
end
