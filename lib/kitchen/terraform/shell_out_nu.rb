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
require "mixlib/shellout"

module Kitchen
  module Terraform
    # Terraform commands are run by shelling out and using the
    # {https://www.terraform.io/docs/commands/index.html command-line interface}, which is assumed to be present in the
    # {https://en.wikipedia.org/wiki/PATH_(variable) PATH} of the user. The shell out environment includes the
    # TF_IN_AUTOMATION environment variable as specified by the
    # {https://www.terraform.io/guides/running-terraform-in-automation.html#controlling-terraform-output-in-automation Running Terraform in Automation guide}.
    module ShellOutNu
      extend ::Kitchen::Logging
      extend ::Kitchen::ShellOut

      class << self
        def logger
          ::Kitchen.logger
        end

        # Runs a Terraform command.
        #
        # @param command [::String] the command to run.
        # @param directory [::String] the directory in which to run the command.
        # @param timeout [::Integer] the maximum duration in seconds to run the command.
        # @raise [::Kitchen::Terraform::Error] if running the command fails.
        # @return [self]
        # @see https://rubygems.org/gems/mixlib-shellout mixlib-shellout
        # @yieldparam output [::String] the output from running the command.
        def run(command:, directory: ::Dir.pwd, timeout: 60_000)
          command.store output: String(
            run_command(
              command.to_s,
              cwd: directory,
              environment: {
                "LC_ALL" => nil,
                "TF_IN_AUTOMATION" => "1",
                "TF_WARN_OUTPUT_ERRORS" => "1",
              },
              timeout: timeout,
            )
          )
        rescue ::Kitchen::ShellOut::ShellCommandFailed, ::Kitchen::Error => error
          raise ::Kitchen::Terraform::Error, error.message
        end
      end
    end
  end
end
