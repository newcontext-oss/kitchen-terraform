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

require "inspec"
require "train"

module Kitchen
  module Terraform
    # InSpec is the class of objects which act as interfaces to InSpec.
    class InSpec
      class << self
        # .logger= sets the logger for all InSpec processes.
        #
        # The logdev of the logger is extended to conform to interface expected by InSpec.
        #
        # @param logger [::Kitchen::Logger] the logger to use.
        # @return [void]
        def logger=(logger)
          logger.logdev.define_singleton_method :filename do
            false
          end

          ::Inspec::Log.logger = logger
        end
      end

      # #exec executes InSpec.
      #
      # @raise [::Kitchen::TransientFailure] if the InSpec Runner exits with a non-zero exit code.
      # @raise [::Kitchen::ClientError] if executing InSpec fails.
      # @return [self]
      def exec
        @runner.run.tap do |exit_code|
          if 0 != exit_code
            raise ::Kitchen::TransientFailure, "InSpec Runner exited with #{exit_code}"
          end
        end

        self
      rescue ::ArgumentError, ::RuntimeError, ::Train::UserError => error
        raise ::Kitchen::ClientError, "Executing InSpec failed\n#{error.message}"
      end

      # #info logs an information message using the InSpec logger.
      #
      # @param message [::String] the message to be logged.
      # @return [self]
      def info(message:)
        ::Inspec::Log.info ::String.new message

        self
      end

      private

      def initialize(options:, profile_locations:)
        @runner = ::Inspec::Runner.new options.merge logger: ::Inspec::Log.logger
        profile_locations.each do |profile_location|
          @runner.add_target profile_location
        end
      end
    end
  end
end
