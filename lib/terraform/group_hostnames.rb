# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'set'

module Terraform
  class GroupHostnames
    def if_undefined
      config_value.scan(/^\s*$/) { yield }
    end

    def resolve(client:, &block)
      resolve_values
      resolved_values.each(&block)
    end

    def to_s
      config_value
    end

    private

    attr_accessor :config_value, :resolved_values

    def initialize(config_value)
      self.config_value = String config_value
      self.resolved_values = ::Set.new
    end

    def resolve_values
      if_undefined { return resolve_values.add 'localhost' }
      client.iterate_output name: config_value, &resolved_values.method(:add)
    end
  end
end
