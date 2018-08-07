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

# Enumerates each system and the hosts of each system.
#
# If a system associates +:hosts_output+ with a value then that value is assumed to be the name of a
# {https://www.terraform.io/docs/configuration/outputs.html Terraform output variable} which has a value of a string or
# array containing one or more hosts; those hosts will be enumerated with the system.
class ::Kitchen::Terraform::SystemAndHostsEnumerator
  # Invokes the function.
  #
  # @raise [::Kitchen::Terraform::Error] if the enumeration fails.
  # @return [void]
  # @yieldparam system [::Hash] the system from which hosts are being enumerated.
  # @yieldparam hostname [::String] a hostname from the system.
  def each_system_and_hosts(&block)
    systems.each do |system|
      self.system = system
      load_output_value
      yield_each_system_and_hosts &block
    end
  end

  private

  attr_accessor :system, :systems, :outputs_with_default, :output_value

  # @api private
  def initialize(systems:, outputs:)
    self.systems = systems
    self.outputs_with_default = Hash[outputs]
    outputs_with_default.store self, "value" => ""
  end

  def load_output_value
    self.output_value = outputs_with_default.fetch(
      system.fetch(:hosts_output) do
        self
      end
    ).fetch "value"
  rescue ::KeyError => key_error
    raise ::Kitchen::Terraform::Error,
          "Enumeration of systems and hosts resulted in failure due to the omission of the configured :hosts_output " \
          "output or an unexpected output structure: #{key_error.message}"
  end

  def yield_each_system_and_hosts
    Array(output_value).each do |host|
      yield system: system, host: host
    end
  end
end
