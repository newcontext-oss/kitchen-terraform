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

require "set"
require "terraform/command_option"

module Terraform
  # Options for commands
  class CommandOptions
    def color=(value)
      value or store key: "no-color"
    end

    def destroy=(value)
      store key: "destroy", value: value
    end

    def input=(value)
      store key: "input", value: value
    end

    def json=(value)
      store key: "json", value: value
    end

    def out
      fetch key: "out"
    end

    def out=(value)
      store key: "out", value: value
    end

    def parallelism=(value)
      store key: "parallelism", value: value
    end

    def state
      fetch key: "state"
    end

    def state=(value)
      store key: "state", value: value
    end

    def state_out
      fetch key: "state-out"
    end

    def state_out=(value)
      store key: "state-out", value: value
    end

    def update=(value)
      store key: "update", value: value
    end

    def var=(value)
      value.each_pair do |variable_name, variable_value|
        store key: "var", value: "'#{variable_name}=#{variable_value}'"
      end
    end

    def var_file=(value)
      value.each do |file| store key: "var-file", value: file end
    end

    def to_s
      options.each_with_object ::String.new do |option, string| string.concat "#{option} " end
    end

    private

    attr_accessor :options

    def fetch(key:)
      options.find do |option| option.key == key end.value
    end

    def initialize(options: ::Set.new)
      self.options = options
    end

    def store(**keyword_arguments)
      options.add ::Terraform::CommandOption.new **keyword_arguments
    end
  end
end
