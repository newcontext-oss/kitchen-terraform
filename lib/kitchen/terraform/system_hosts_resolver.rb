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

require "kitchen"

module Kitchen
  module Terraform
    # SystemHostsResolver is the class of objects which resolve for systems the hosts which are contained in outputs.
    class SystemHostsResolver
      # #resolve resolves the hosts.
      #
      # @param hosts_output [::String] the name of the Terraform output which has a value of hosts for the system.
      # @param system [::Kitchen::Terraform::System] the system.
      # @raise [::Kitchen::Terraform::Error] if the fetching the value of the output fails.
      def resolve(hosts_output:, system:)
        system.add_hosts hosts: @outputs.fetch(hosts_output.to_sym).fetch(:value)
      rescue ::KeyError => key_error
        @logger.error(
          "The key '#{hosts_output}' was not found in the Terraform outputs of the Kitchen instance state. This " \
          "error could indicate that the wrong key was provided or that the Kitchen instance state was modified " \
          "after `kitchen converge` was executed."
        )

        raise ::Kitchen::ClientError, "Failed resolution of hosts."
      end

      private

      def initialize(logger:, outputs:)
        @logger = logger
        @outputs = Hash[outputs]
      end
    end
  end
end
