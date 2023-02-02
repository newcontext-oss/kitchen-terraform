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

module Kitchen
  module Terraform
    module Driver
      # Doctor checks for driver configuration errors.
      class Doctor
        # #call executes the action.
        #
        # @param config [Hash] the configuration of the driver.
        # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
        def call(config:)
          errors = false
          client = config.fetch :client

          if !::File.exist? client
            errors = true
            logger.error "#{instance_name}.driver.client '#{client}' does not exist"
          end
          if !::File.executable? client
            errors = true
            logger.error "#{instance_name}.driver.client '#{client}' is not executable"
          end

          errors
        end

        # #initialize prepares a new instance of the class.
        #
        # @param instance_name [String] the name of the Kitchen instance.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @option config [String] :client the pathname of the Terraform client.
        # @return [Kitchen::Terraform::Driver::Doctor]
        def initialize(instance_name:, logger:)
          self.instance_name = instance_name
          self.logger = logger
        end

        private

        attr_accessor :logger, :instance_name
      end
    end
  end
end
