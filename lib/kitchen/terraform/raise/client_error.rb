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
    module Raise
      # ClientError is the class of objects which handle errors that are caused by incorrect use of an API.
      class ClientError
        # #call logs an error message and raises an error with the message.
        #
        # @param message [String] the error message.
        # @raise [Kitchen::ClientError]
        # @return [void]
        def call(message:)
          logger.error message

          raise ::Kitchen::ClientError, message
        end

        # #initialize prepares a new instance of the class.
        #
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @return [Kitchen::Terraform::ClientError]
        def initialize(logger:)
          self.logger = logger
        end

        private

        attr_accessor :logger
      end
    end
  end
end
