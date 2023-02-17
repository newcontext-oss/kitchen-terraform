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
      # Connection is a class of objects which are responsible for carrying out Terraform CLI commands.
      class Connection < ::Kitchen::Transport::Exec::Connection
        # #execute executes a Terraform CLI command on the local host.
        #
        # @param command [String] the command to be executed.
        # @raise [TransportFailed] if the command does not exit successfully.
        def execute(command)
          super "#{client} #{command}"
        end

        private

        attr_accessor :client

        # #init_options initializes incoming options for use by the object.
        #
        # @param options [Hash] configuration options.
        # @return [void]
        def init_options(options)
          super
          self.client = @options.delete :client
        end
      end
    end
  end
end
