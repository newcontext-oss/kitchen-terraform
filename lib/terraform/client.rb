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

require 'pathname'
require_relative 'apply_command'
require_relative 'get_command'
require_relative 'output_command'
require_relative 'plan_command'
require_relative 'validate_command'
require_relative 'version_command'

module Terraform
  # Runs Mixlib Terraform Command instances
  class Client
    extend Forwardable

    attr_reader :supported_version

    def apply_execution_plan
      run command_class: ApplyCommand, timeout: apply_timeout,
          state: state_pathname, plan: plan_pathname
    end

    def download_modules
      run command_class: GetCommand, dir: directory
    end

    def instance_directory
      kitchen_root.join '.kitchen', 'kitchen-terraform', instance_name
    end

    def list_output(name:)
      output(name: name).split ','
    end

    def output(name:)
      run(
        command_class: OutputCommand, state: state_pathname, name: name
      ) { |output| return output.chomp }
    end

    def plan_destructive_execution
      run command_class: PlanCommand, destroy: true, out: plan_pathname,
          state: state_pathname, var: variables, var_file: variable_files,
          dir: directory
    end

    def plan_execution
      run command_class: PlanCommand, destroy: false, out: plan_pathname,
          state: state_pathname, var: variables, var_file: variable_files,
          dir: directory
    end

    def plan_pathname
      instance_directory.join 'terraform.tfplan'
    end

    def run(command_class:, **parameters, &block)
      command_class.new(logger: logger, **parameters) do |command|
        logger.info command
        command.execute(&block)
      end
    end

    def state_pathname
      instance_directory.join 'terraform.tfstate'
    end

    def validate_configuration_files
      run command_class: ValidateCommand, dir: directory
    end

    def validate_version
      run command_class: VersionCommand do |output|
        break if supported_version.match output

        raise ::Terraform::UserError,
              "Terraform version must match #{supported_version}"
      end
    end

    private

    attr_accessor :apply_timeout, :directory, :instance_name, :kitchen_root,
                  :logger, :variable_files, :variables

    attr_writer :supported_version

    def initialize(instance_name:, logger:, provisioner:)
      self.apply_timeout = provisioner[:apply_timeout]
      self.directory = provisioner[:directory]
      self.instance_name = instance_name
      self.kitchen_root = Pathname.new provisioner[:kitchen_root]
      self.logger = logger
      self.supported_version = /v0.6/
      self.variable_files = provisioner[:variable_files]
      self.variables = provisioner[:variables]
    end
  end
end
