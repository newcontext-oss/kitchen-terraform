# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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
require "kitchen/terraform/shell_out"

module Kitchen
  module Terraform
    module Command
      # Get is the class of objects which represent the <tt>terraform get</tt> command.
      class Get
        class << self
          # Initializes an instance by running `terraform get`.
          #
          # @param directory [::String] the directory in which to run the command.
          # @param timeout [::Integer] the maximum duration in seconds to run the command.
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [self]
          # @yieldparam get [::Kitchen::Terraform::Command::Get] an instance initialized with the output of the command.
          def run(directory:, timeout:)
            new.tap do |get|
              ::Kitchen::Terraform::ShellOut.run(
                command: get,
                directory: directory,
                timeout: timeout,
              )

              yield get: get if block_given?
            end

            self
          end
        end

        def ==(get)
          to_s == get.to_s
        end

        def store(output:)
          @output = output

          self
        end

        def to_s
          "terraform get -update"
        end
      end
    end
  end
end
