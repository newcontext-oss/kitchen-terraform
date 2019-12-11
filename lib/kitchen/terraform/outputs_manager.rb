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
    # OutputsManager manages Terraform outputs in the Kitchen instance state.
    class OutputsManager
      # #load reads the Terraform outputs from the Kitchen instance state and writes them to a container.
      #
      # @param outputs [::Hash] the container to which the Terraform outputs will be written.
      # @param state [::Hash] the Kitchen instance state from which the Terraform outputs will be read.
      # @return [self]
      def load(outputs:, state:)
        outputs.replace state.fetch @state_key

        self
      rescue ::KeyError => error
        @logger.error(
          "The '#{@state_key}' key was not found in the Kitchen instance state. This error could indicate that the " \
          "Kitchen-Terraform provisioner plugin was not used to converge the Kitchen instance."
        )

        raise ::Kitchen::ClientError, "Failed retrieval of Terraform outputs from the Kitchen instance state."
      end

      # #save reads the Terraform outputs from container and writes them to the Kitchen instance state.
      #
      # @param outputs [::Hash] the container from which the Terraform outputs will be read.
      # @param state [::Hash] the Kitchen instance state to which the Terraform outputs will be written.
      # @return [self]
      def save(outputs:, state:)
        state.store @state_key, outputs.dup

        self
      end

      private

      def initialize(logger:)
        @state_key = :kitchen_terraform_outputs
        @logger = logger
      end
    end
  end
end
