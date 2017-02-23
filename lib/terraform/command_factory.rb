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

require 'terraform/apply_command'
require 'terraform/destructive_plan_command'
require 'terraform/get_command'
require 'terraform/output_command'
require 'terraform/plan_command'
require 'terraform/show_command'
require 'terraform/validate_command'
require 'terraform/version_command'

module Terraform
  # A factory to create commands
  class CommandFactory
    def apply_command
      ::Terraform::ApplyCommand.new target: config[:plan] do |options|
        options.color = config[:color]
        options.input = false
        options.parallelism = config[:parallelism]
        options.state = config[:state]
      end
    end

    def destructive_plan_command
      ::Terraform::DestructivePlanCommand
        .new target: config[:directory] do |options|
          configure_plan options: options
          options.destroy = true
        end
    end

    def get_command
      ::Terraform::GetCommand.new target: config[:directory] do |options|
        options.update = true
      end
    end

    def output_command(target:, version:)
      version
        .if_json_not_supported { return base_output_command target: target }

      json_output_command target: target
    end

    def plan_command
      ::Terraform::PlanCommand.new target: config[:directory] do |options|
        configure_plan options: options
      end
    end

    def show_command
      ::Terraform::ShowCommand.new target: config[:state] do |options|
        options.color = config[:color]
      end
    end

    def validate_command
      ::Terraform::ValidateCommand.new target: config[:directory]
    end

    def version_command
      ::Terraform::VersionCommand.new
    end

    private

    attr_accessor :config

    def base_output_command(target:, &block)
      block ||= proc {}

      ::Terraform::OutputCommand.new target: target do |options|
        options.color = config[:color]
        options.state = config[:state]
        block.call options
      end
    end

    def configure_plan(options:)
      options.color = config[:color]
      options.input = false
      options.out = config[:plan]
      options.parallelism = config[:parallelism]
      options.state = config[:state]
      options.var = config[:variables]
      options.var_file = config[:variable_files]
    end

    def initialize(config:)
      self.config = config
    end

    def json_output_command(target:)
      base_output_command(target: target) { |options| options.json = true }
    end
  end
end
