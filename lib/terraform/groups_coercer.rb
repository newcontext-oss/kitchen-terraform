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

require 'hashie/extensions/coercion'
require_relative 'groups'

module Terraform
  # A coercer for [:groups] config values
  class GroupsCoercer
    def coerce(attr:, value:)
      configurable[attr] =
        ::Terraform::Groups.new Array(value).map(&method(:Hash))
    rescue ::TypeError, ::Hashie::CoercionError
      configurable.config_error attr: attr, expected: 'a group mapping'
    end

    private

    attr_accessor :configurable

    def initialize(configurable:)
      self.configurable = configurable
    end
  end
end
