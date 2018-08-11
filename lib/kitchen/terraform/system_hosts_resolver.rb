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

require "kitchen/terraform"
require "kitchen/terraform/error"

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
        system.add_hosts hosts: @outputs.fetch(hosts_output).fetch("value")
      rescue ::KeyError => key_error
        raise ::Kitchen::Terraform::Error, "Resolving the hosts of system #{system} failed\n#{key_error}"
      end

      private

      # #initialize prepares the instance to be used.
      #
      # @param outputs [#to_hash] the outputs of the Terraform state under test.
      def initialize(outputs:)
        @outputs = Hash[outputs]
      end
    end
  end
end
