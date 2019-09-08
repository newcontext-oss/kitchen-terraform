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
      # Strict is the class of objects which provide a strict strategy for VersionVerifiers.
      class Strict
        # #supported informs the user that the version is supported.
        def supported
          @logger.info "The Terraform client version is supported."

          self
        end

        # #unsupported informs the user that the version is not supported and raises an error.
        def unsupported
          @logger.error(
            "The Terraform client version is not supported. Set `driver.verify_version: false` to downgrade this " \
            "error to a warning."
          )

          raise ::Kitchen::UserError, "Failed verification of the Terraform client version."
        end

        private

        def initialize(logger:)
          @logger = logger
        end
      end
    end
  end
end
