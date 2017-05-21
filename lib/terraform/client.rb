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

require "terraform/command_factory"
require "terraform/no_output_parser"
require "terraform/no_output_search_parser"
require "terraform/output_parser"
require "terraform/output_search_parser"
require "terraform/shell_out"

module Terraform
  # Client to execute commands
  class Client
    def apply_constructively
      apply plan_command: factory.plan_command
    end

    def apply_destructively
      apply plan_command: factory.destructive_plan_command
    end

    def load_state(&block)
      execute command: factory.show_command do |state| /\w+/.match state, &block end
    end

    def output_search(name:)
      output_search_parser(name: name).parsed_output
    end

    def output()
      output_parser().parsed_output
    end

    def version
      @version ||= execute command: factory.version_command do |value|
        execute command: factory.version_command do |value| return value.slice /v(\d+\.\d+\.\d+)/, 1 end
      end
    end

    private

    attr_accessor :apply_timeout, :cli, :factory, :logger

    def apply(plan_command:)
      execute command: factory.validate_command
      execute command: factory.get_command
      execute command: plan_command
      ::Terraform::ShellOut
        .new(cli: cli, command: factory.apply_command, logger: logger, timeout: apply_timeout).execute
    end

    def execute(command:, &block)
      ::Terraform::ShellOut.new(cli: cli, command: command, logger: logger).execute &block
    end

    def initialize(config: {}, logger:)
      self.apply_timeout = config[:apply_timeout]
      self.cli = config[:cli]
      self.factory = ::Terraform::CommandFactory.new config: config
      self.logger = logger
    end

    def output_search_parser(name:)
      execute command: factory.output_command(target: name) do |value|
        return ::Terraform::OutputSearchParser.new output: value
      end
    rescue ::Kitchen::StandardError => exception
      /no outputs/.match? exception.message or raise exception
      ::Terraform::NoOutputSearchParser.new
    end

    def output_parser()
      execute command: factory.output_command(target: "") do |value|
        return ::Terraform::OutputParser.new output: value
      end
    rescue ::Kitchen::StandardError => exception
      /no outputs/.match? exception.message or raise exception
      ::Terraform::NoOutputParser.new
    end
  end
end
