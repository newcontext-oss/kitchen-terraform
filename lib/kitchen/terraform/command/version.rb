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
require "kitchen/terraform/error"
require "rubygems"

module Kitchen
  module Terraform
    module Command
      # Version is the class of objects which represent the <tt>terraform version</tt> command.
      class Version < ::Gem::Version
        extend ::Kitchen::Logging
        extend ::Kitchen::ShellOut

        class << self
          # The command is run by shelling out in an environment which is optimized for automating Terraform.
          #
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [::Kitchen::Terraform::Command::Version] an instance initialized with the output of the command.
          # @yieldparam version [::Kitchen::Terraform::Command::Version] an instance initialized with the output of the
          #   command.
          def run
            new(
              run_command(
                "terraform version",
                environment: {
                  "LC_ALL" => nil,
                  "TF_IN_AUTOMATION" => "true",
                  "TF_WARN_OUTPUT_ERRORS" => "true",
                },
              )
            ).tap do |version|
              yield version: version
            end
          rescue ::Kitchen::ShellOut::ShellCommandFailed, ::Kitchen::Error => error
            raise ::Kitchen::Terraform::Error, error.message
          end

          private

          def logger
            ::Kitchen.logger
          end
        end

        private

        def initialize(version)
          super version.slice(/Terraform v(\d+\.\d+\.\d+)/, 1)
        end
      end
    end
  end
end
