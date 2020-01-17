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

module Kitchen
  module Terraform
    # InSpecRunner is the class of objects which act as interfaces to the InSpec gem.
    class InSpecRunner
      class << self
        # .logger= sets the logger for all InSpec processes.
        #
        # The logdev of the logger is extended to conform to interface expected by InSpec.
        #
        # @param logger [::Kitchen::Logger] the logger to use.
        # @return [::Kitchen::Logger] the logger.
        def logger=(logger)
          logger.logdev.define_singleton_method :filename do
            false
          end

          ::Inspec::Log.logger = logger
        end
      end

      # #exec executes InSpec.
      #
      # @raise [::Kitchen::ClientError] if the execution of InSpec fails.
      # @return [self]
      def exec
        if 0 != exit_code
          raise "InSpec Runner exited with #{exit_code}."
        end

        self
      rescue => error
        raise ::Kitchen::ClientError, error.message
      end

      private

      attr_accessor :runner

      def exit_code
        @exit_code ||= runner.run
      end

      def initialize(options:, profile_locations:)
        self.runner = ::Inspec::Runner.new options.merge logger: ::Inspec::Log.logger
        profile_locations.each do |profile_location|
          runner.add_target profile_location
        end
      end
    end
  end
end
