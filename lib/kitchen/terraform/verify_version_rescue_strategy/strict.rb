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

require "kitchen/terraform/unsupported_client_version_error"

module Kitchen
  module Terraform
    module VerifyVersionRescueStrategy
      # Strict is the class of objects which provide a strict strategy rescue strategy to handle a failure to verify the
      # Terraform client version.
      class Strict
        # #call raises an error.
        #
        # @raise [Kitchen::Terraform::UnsupportedClientVersionError]
        # @return [void]
        def call
          raise ::Kitchen::Terraform::UnsupportedClientVersionError, message
        end

        # #initialize prepares a new instance of the class.
        #
        # @return [Kitchen::Terraform::VerifyVersionRescueStrategy::Permissive]
        def initialize
          self.message = "Verifying the Terraform client version failed. Set `driver.verify_version: false` to " \
                         "downgrade this error to a warning."
        end

        private

        attr_accessor :message
      end
    end
  end
end
