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

require "json"
require "kitchen"
require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/error"
require "kitchen/terraform/shell_out_nu"

module Kitchen
  module Terraform
    module Command
      # Output is the class of objects which represent the <tt>terraform output</tt> command.
      class Output
        class << self
          # Initializes an instance by running <tt>terraform output</tt>.
          #
          # @param color [true, false] a toggle for colored output.
          # @param directory [::String] the directory in which to run the command.
          # @param timeout [::Integer] the maximum duration in seconds to run the command.
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [self]
          # @yieldparam output [::Kitchen::Terraform::Command::Destroy] an instance initialized with the output of the
          #   command.
          def run(color:, directory:, timeout:)
            new(color: color).tap do |output|
              shell_out directory: directory, output: output, timeout: timeout
              yield output: output
            end

            self
          end

          private

          def shell_out(directory:, output:, timeout:)
            ::Kitchen::Terraform::ShellOutNu.run command: output, directory: directory, timeout: timeout
          rescue ::Kitchen::Terraform::Error => error
            if /no\\ outputs\\ defined/.match ::Regexp.escape error.message
              output.store output: "{}"
            else
              raise error
            end
          end
        end

        def ==(output)
          to_s == output.to_s
        end

        def retrieve_outputs
          yield outputs: @output

          self
        end

        def store(output:)
          @output = ::Kitchen::Util.stringified_hash ::JSON.parse output

          self
        rescue ::JSON::ParserError => error
          raise ::Kitchen::Terraform::Error, "Parsing Terraform output as JSON failed: #{error.message}"
        end

        def to_s
          ::Kitchen::Terraform::CommandFlag::Color.new(
            command: ::String.new("terraform output -json"),
            color: @color,
          ).to_s
        end

        private

        def initialize(color:)
          @color = color
        end
      end
    end
  end
end
