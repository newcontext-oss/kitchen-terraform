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

require_relative 'group'

module Terraform
  # Behaviour for the [:groups] config option
  module GroupsConfig
    def self.included(configurable_class)
      configurable_class.required_config :groups do |_, value, configurable|
        configurable.coerce_groups value: value
      end
      configurable_class.default_config :groups, []
    end

    def coerce_attributes(group:)
      group[:attributes] = Hash group[:attributes]
    rescue TypeError
      config_error attribute: "groups][#{group}][:attributes",
                   expected: 'a mapping of Inspec attribute names to ' \
                               'Terraform output variable names'
    end

    def coerce_controls(group:)
      group[:controls] = Array group[:controls]
    end

    def coerce_groups(value:)
      config[:groups] = Array(value).map do |group|
        Group.new data: coerced_group(value: group)
      end
    end

    def coerce_hostnames(group:)
      group[:hostnames] = String group[:hostnames]
    end

    def coerce_name(group:)
      group[:name] = String group[:name]
    end

    def coerce_port(group:)
      group[:port] = Integer group.fetch(:port) { transport[:port] }
    rescue ArgumentError, TypeError
      config_error attribute: "groups][#{group}][:port", expected: 'an integer'
    end

    def coerce_username(group:)
      group[:username] = String group.fetch(:username) { transport[:username] }
    end

    def coerced_group(value:)
      Hash(value).tap do |group|
        coerce_attributes group: group
        coerce_controls group: group
        coerce_hostnames group: group
        coerce_name group: group
        coerce_port group: group
        coerce_username group: group
      end
    rescue TypeError
      config_error attribute: "groups][#{value}", expected: 'a group mapping'
    end
  end
end
