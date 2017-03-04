# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require 'hashie'
require 'terraform/group'

module Terraform
  # A coercer for [:groups] config values
  class GroupsCoercer
    def coerce(attr:, value:)
      configurable[attr] = Array(value).map do |group|
        ::Terraform::Group.new defaults.merge group
      end
    rescue ::TypeError, ::Hashie::CoercionError
      configurable.config_error attr: attr, expected: 'a list of group mappings'
    end

    private

    attr_accessor :configurable, :defaults

    def initialize(configurable:)
      self.configurable = configurable
      self.defaults = {
        port: configurable.transport[:port],
        username: configurable.transport[:username]
      }
    end
  end
end
