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
require_relative 'get_command'
require_relative 'output_command'
require_relative 'plan_command'
require_relative 'validate_command'
require_relative 'version_command'

module Terraform
  # Runs Mixlib Terraform Command instances
  class Client
    extend Forwardable

    def_delegators :provisioner, :directory, :info, :kitchen_root,
                   :variable_files, :variables

    def apply_execution_plan
      run command_class: ApplyCommand, state: state_pathname,
          plan: plan_pathname
    end

    def download_modules
      run command_class: GetCommand, dir: directory
    end

    def extract_list_output(name:)
      extract_output(name: name) { |output| yield output.split ',' }
    end

    def extract_output(name:)
      run(
        command_class: OutputCommand, state: state_pathname, name: name
      ) { |output| yield output.chomp }
    end

    def fetch_version
      run(command_class: VersionCommand) { |output| yield output }
    end

    def instance_directory
      kitchen_root.join '.kitchen', 'kitchen-terraform', instance_name
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

    def run(command_class:, **parameters)
      command_class.new(**parameters) do |command|
        info command
        command.execute do |output|
          info output
          yield output if block_given?
        end
      end
    end

    def state_pathname
      instance_directory.join 'terraform.tfstate'
    end

    def validate_configuration_files
      run command_class: ValidateCommand, dir: directory
    end

    private

    attr_accessor :instance_name, :provisioner

    def initialize(instance:)
      self.instance_name = instance.name
      self.provisioner = instance.provisioner
    end
  end
end
