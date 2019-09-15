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
    # VariablesManager manages Terraform input variables in the Kitchen instance state.
    class VariablesManager
      def load(variables:, state:)
        variables.replace state.fetch @state_key

        self
      rescue ::KeyError => error
        @logger.error(
          "The '#{@state_key}' key was not found in the Kitchen instance state. This error could indicate that the " \
          "Kitchen-Terraform provisioner plugin was not used to converge the Kitchen instance."
        )

        raise ::Kitchen::ClientError, "Failed retrieval of Terraform input variables from the Kitchen instance state."
      end

      def save(variables:, state:)
        state.store @state_key, variables

        self
      end

      private

      def initialize(logger:)
        @state_key = :kitchen_terraform_variables
        @logger = logger
      end
    end
  end
end
