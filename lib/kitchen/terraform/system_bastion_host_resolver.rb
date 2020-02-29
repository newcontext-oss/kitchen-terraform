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
    # SystemBastionHostResolver is the class of objects which resolve a bastion host of a system which may be either
    # dynamically obtained from a Terraform output variable or statically defined.
    class SystemBastionHostResolver
      # #initialize prepares a new instance of the class.
      #
      # @param outputs [Hash] a map of Terraform output variables.
      # @return [Kitchen::Terraform::SystemBastionHostResolver]
      def initialize(outputs:)
        self.outputs = Hash[outputs]
      end

      # #resolve resolves a bastion host from either the specified Terraform output or the static value.
      #
      # @param bastion_host [String] a statically defined host.
      # @param bastion_host_output [String] the name of the Terraform output which contains a bastion host.
      # @yieldparam bastion_host [String] the bastion host.
      # @raise [Kitchen::ClientError] if the specified Terraform output is not found.
      # @return [self]
      def resolve(bastion_host:, bastion_host_output:)
        if !bastion_host.empty?
          yield bastion_host: bastion_host
        elsif !bastion_host_output.empty?
          yield bastion_host: resolved_output(bastion_host_output: bastion_host_output).fetch(:value)
        end

        self
      rescue ::KeyError
        raise(
          ::Kitchen::ClientError,
          "Resolving the system bastion host failed due to the absence of the 'value' key from the " \
          "'#{bastion_host_output}' Terraform output of the Kitchen instance state. This error indicates that the " \
          "output format of `terraform output -json` is unexpected."
        )
      end

      private

      attr_accessor :outputs

      def resolved_output(bastion_host_output:)
        outputs.fetch bastion_host_output.to_sym
      rescue ::KeyError
        raise(
          ::Kitchen::ClientError,
          "Resolving the system bastion host failed due to the absence of the '#{bastion_host_output}' key from the " \
          "Terraform outputs of the Kitchen instance state. This error indicates either that `kitchen converge` must " \
          "be executed again to update the Terraform outputs or that the wrong key was provided."
        )
      end
    end
  end
end
