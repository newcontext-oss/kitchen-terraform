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

require "kitchen/transport/exec"

module Kitchen
  module Terraform
    module Transport
      # Terraform commands are run by shelling out and using the
      # {https://www.terraform.io/docs/commands/index.html command-line interface}.
      #
      # The shell out environment includes the TF_IN_AUTOMATION environment variable as specified by the
      # {https://www.terraform.io/guides/running-terraform-in-automation.html#controlling-terraform-output-in-automation Running Terraform in Automation guide}.
      class Connection < ::Kitchen::Transport::Exec::Connection
        # #run_command executes a Terraform CLI command in a subshell on the local running system.
        #
        # @param cmd [String] the command to be executed locally.
        # @param options [Hash] additional configuration of the command.
        # @return [String] the standard output of the command.
        # @raise [ShellCommandFailed] if the command fails.
        # @raise [Error] for all other unexpected exceptions.
        def run_command(command, options = {})
          super "#{client} #{command}", options.merge(environment: { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true" })
        end

        private

        attr_accessor :client

        # #init_options initializes incoming options for use by the object.
        #
        # @param options [Hash] configuration options.
        # @return [void]
        # @api private
        def init_options(options)
          super
          self.client = @options.delete :client
        end
      end
    end
  end
end
