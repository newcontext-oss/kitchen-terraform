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

require "kitchen/terraform/command_flag/color"
require "shellwords"

module Kitchen
  module Terraform
    module Command
      module Validate
        # The root module is validated by running a command like the following example:
        #   terraform validate \
        #     [-no-color] \
        #     <directory>
        class PostZeroFifteenZero
          # #initialize prepares a new instance of the class.
          #
          # @param config [Hash] the configuration of the driver.
          # @option config [Boolean] :color a toggle of colored output from the Terraform client.
          # @return [Kitchen::Terraform::Command::Validate]
          def initialize(config:)
            self.color = ::Kitchen::Terraform::CommandFlag::Color.new enabled: config.fetch(:color)
          end

          # @return [String] the command with flags.
          def to_s
            "validate " \
            "#{color}"
          end

          private

          attr_accessor :color
        end
      end
    end
  end
end
