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
    # SystemHostsResolver is the class of objects which resolve the hosts of a system which are contained in Terraform
    # outputs.
    class SystemHostsResolver
      # #resolve reads the specified Terraform output and stores the value in a list of hosts.
      #
      # @param hosts [::Array] the list of hosts.
      # @param hosts_output [::String] the name of the Terraform output which contains hosts.
      # @raise [::Kitchen::ClientError] if the specified Terraform output is not found.
      # @return [self]
      def resolve(hosts:, hosts_output:)
        hosts.concat Array resolved_output(hosts_output: hosts_output).fetch :value

        self
      rescue ::KeyError
        @logger.error(
          "The 'value' key was not found in the '#{hosts_output}' Terraform output of the Kitchen instance " \
          "state. This error indicates that the output format of `terraform output -json` is unexpected."
        )

        raise ::Kitchen::ClientError, "Failed resolution of hosts."
      end

      private

      def resolved_output(hosts_output:)
        @outputs.fetch hosts_output.to_sym
      rescue ::KeyError
        @logger.error(
          "The '#{hosts_output}' key was not found in the Terraform outputs of the Kitchen instance state. This " \
          "error indicates that `kitchen converge` must be executed again to update the Terraform outputs or that " \
          "the wrong key was provided."
        )

        raise ::Kitchen::ClientError, "Failed resolution of hosts."
      end

      def initialize(logger:, outputs:)
        @logger = logger
        @outputs = Hash[outputs]
      end
    end
  end
end
