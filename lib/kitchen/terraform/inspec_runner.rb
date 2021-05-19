# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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
require "kitchen"

module Kitchen
  module Terraform
    # InSpecRunner is the class of objects which act as interfaces to the InSpec gem.
    class InSpecRunner
      class << self
        # .logger= sets the logger for all InSpec processes.
        #
        # The logdev of the logger is extended to conform to interface expected by InSpec.
        #
        # @param logger [Kitchen::Logger] the logger to use.
        # @return [Kitchen::Logger] the logger.
        def logger=(logger)
          logger.logdev.define_singleton_method :filename do
            false
          end

          ::Inspec::Log.logger = logger
        end
      end

      # #exec executes InSpec.
      #
      # @raise [Kitchen::TransientFailure] if the execution of InSpec fails.
      # @return [self]
      def exec
        run do |exit_code:|
          if 0 != exit_code
            raise ::Kitchen::TransientFailure, "#{action} failed due to a non-zero exit code of #{exit_code}."
          end
        end

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param options [Hash] options to configure the runner.
      # @param profile_locations [Array<String>] a list of pathnames of profiles.
      # @return [Kitchen::Terraform::InSpecRunner]
      def initialize(options:, profile_locations:)
        self.host = options.fetch :host do
          ""
        end

        ::Inspec::Plugin::V2::Loader.new.tap do |loader|
          loader.load_all
          loader.exit_on_load_error
        end

        self.runner = ::Inspec::Runner.new options.merge logger: ::Inspec::Log.logger

        profile_locations.each do |profile_location|
          runner.add_target profile_location
        end
      end

      private

      attr_accessor :host, :runner

      def action
        if host.empty?
          "Running InSpec"
        else
          "Running InSpec against the '#{host}' host"
        end
      end

      def run
        yield exit_code: runner.run
      rescue => error
        raise ::Kitchen::TransientFailure, "#{action} failed:\n\t\t#{error.message}"
      end
    end
  end
end
