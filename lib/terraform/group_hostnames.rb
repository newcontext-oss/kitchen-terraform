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

module Terraform
  # Hostnames output variable for Group
  class GroupHostnames
    def resolve(client:, &block)
      config_value.scan(/^\s*$/) { return yield 'localhost' }

      client.iterate_output name: config_value, &block
    end

    def to_s
      config_value
    end

    private

    attr_accessor :config_value

    def initialize(config_value = '')
      self.config_value = String config_value
    end
  end
end
