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

# Enumerates each group and the hosts of each group.
#
# If a group associates +:hosts_output+ with a value then that value is assumed to be the name of a
# {https://www.terraform.io/docs/configuration/outputs.html Terraform output variable} which has a value of a string or
# array containing one or more hosts; those hosts will be enumerated with the group.
class ::Kitchen::Terraform::GroupAndHostsEnumerator
  # Invokes the function.
  #
  # @raise [::Kitchen::Terraform::Error] if the enumeration fails.
  # @return [void]
  # @yieldparam group [::Hash] the group from which hosts are being enumerated.
  # @yieldparam hostname [::String] a hostname from the group.
  def each_group_and_hosts(&block)
    groups.each do |group|
      self.group = group
      load_output_value
      yield_each_group_and_hosts &block
    end
  end

  private

  attr_accessor :group, :groups, :outputs_with_default, :output_value

  # @api private
  def initialize(groups:, outputs:)
    self.groups = groups
    self.outputs_with_default = Hash[outputs]
    outputs_with_default.store self, "value" => ""
  end

  def load_output_value
    self.output_value = outputs_with_default.fetch(
      group.fetch(:hosts_output) do
        self
      end
    ).fetch "value"
  rescue ::KeyError => key_error
    raise ::Kitchen::Terraform::Error,
          "Enumeration of groups and hosts resulted in failure due to the omission of the configured :hosts_output " \
            "output or an unexpected output structure: #{key_error.message}"
  end

  def yield_each_group_and_hosts
    Array(output_value).each do |host|
      yield group: group, host: host
    end
  end
end
