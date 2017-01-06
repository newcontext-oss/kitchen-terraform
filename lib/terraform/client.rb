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

require_relative 'command_factory'
require_relative 'invoker'
require_relative 'output_parser'
require_relative 'version'

module Terraform
  # Client to execute commands
  class Client
    def apply_constructively
      apply { invoker.execute command: factory.plan_command }
    end

    def apply_destructively
      apply { invoker.execute command: factory.destructive_plan_command }
    end

    def each_output_name(&block)
      output_parser(name: '').each_name(&block)
    end

    def iterate_output(name:, &block)
      output_parser(name: name).iterate_parsed_output(&block)
    end

    def load_state(&block)
      invoker.execute(command: factory.show_command) do |state|
        /\w+/.match state, &block
      end
    end

    def output(name:)
      output_parser(name: name).parsed_output
    end

    def version
      invoker.execute command: factory.version_command do |value|
        return ::Terraform::Version.new value: value
      end
    end

    private

    attr_accessor :apply_timeout, :factory, :invoker

    def apply
      invoker.execute command: factory.validate_command
      invoker.execute command: factory.get_command
      yield
      invoker.execute command: factory.apply_command, timeout: apply_timeout
    end

    def if_json_supported
      [::Terraform::Version.new(value: '0.7')].find proc { return },
                                                    &version.method(:==)

      yield
    end

    def initialize(config: {}, logger:)
      self.apply_timeout = config[:apply_timeout]
      self.factory = ::Terraform::CommandFactory.new config: config
      self.invoker = ::Terraform::Invoker.new logger: logger
    end

    def output_command(target:)
      if_json_supported { return factory.json_output_command target: target }

      factory.output_command target: target
    end

    def output_parser(name:)
      invoker.execute command: output_command(target: name) do |value|
        return ::Terraform::OutputParser.new value: value
      end
    end
  end
end
