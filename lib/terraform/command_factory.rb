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

require_relative 'apply_command'
require_relative 'command'
require_relative 'destructive_plan_command'
require_relative 'get_command'
require_relative 'output_command'
require_relative 'plan_command'
require_relative 'show_command'
require_relative 'validate_command'
require_relative 'version_command'

module Terraform
  # A factory to create commands
  class CommandFactory
    def apply_command
      ::Terraform::Command.new subcommand: ::Terraform::ApplyCommand,
                               target: config[:plan] do |options|
        options.color = config[:color]
        options.state = config[:state]
      end
    end

    def destructive_plan_command
      ::Terraform::Command
        .new subcommand: ::Terraform::DestructivePlanCommand,
             target: config[:directory] do |options|
        configure_plan options: options
        options.state = config[:state]
      end
    end

    def get_command
      ::Terraform::Command.new subcommand: ::Terraform::GetCommand,
                               target: config[:directory]
    end

    def json_output_command(target:)
      output_command(target: target) { |options| options.json = true }
    end

    def output_command(target:, &block)
      block ||= proc {}

      ::Terraform::Command.new subcommand: ::Terraform::OutputCommand,
                               target: target do |options|
        options.color = config[:color]
        options.state = config[:state]
        block.call options
      end
    end

    def plan_command
      ::Terraform::Command.new subcommand: ::Terraform::PlanCommand,
                               target: config[:directory] do |options|
        configure_plan options: options
      end
    end

    def show_command
      ::Terraform::Command.new subcommand: ::Terraform::ShowCommand,
                               target: config[:state] do |options|
        options.color = config[:color]
      end
    end

    def validate_command
      ::Terraform::Command.new subcommand: ::Terraform::ValidateCommand,
                               target: config[:directory]
    end

    def version_command
      ::Terraform::Command.new subcommand: ::Terraform::VersionCommand
    end

    private

    attr_accessor :config

    def configure_plan(options:)
      options.color = config[:color]
      options.out = config[:plan]
      options.var = config[:variables]
      options.var_file = config[:variable_files]
    end

    def initialize(config:)
      self.config = config
    end
  end
end
