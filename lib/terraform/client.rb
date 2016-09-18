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

require 'kitchen'
require_relative 'apply_command'
require_relative 'command_executor'
require_relative 'get_command'
require_relative 'output_command'
require_relative 'plan_command'
require_relative 'validate_command'
require_relative 'version_command'

module Terraform
  # Behaviour for implementing the workflow
  module Client
    include CommandExecutor

    def apply_execution_plan
      execute command: ApplyCommand.new(
        color: provisioner[:color], state: provisioner[:state],
        target: provisioner[:plan]
      ), timeout: provisioner[:apply_timeout]
    end

    def download_modules
      execute command: GetCommand.new(target: provisioner[:directory])
    end

    def each_list_output(name:, &block)
      output(name: name).split(',').each(&block)
    end

    def output(name:)
      execute command: OutputCommand
        .new(state: provisioner[:state], target: name), &:chomp
    end

    def plan_execution(destroy:)
      execute command: PlanCommand.new(
        color: provisioner[:color], destroy: destroy, out: provisioner[:plan],
        state: provisioner[:state], target: provisioner[:directory],
        variables: provisioner[:variables],
        variable_files: provisioner[:variable_files]
      )
    end

    def validate_configuration_files
      execute command: ValidateCommand
        .new(target: provisioner[:directory])
    end

    def validate_installed_version
      execute command: VersionCommand.new do |version|
        raise Kitchen::UserError,
              'Only Terraform versions 0.6.z and 0.7.z are supported' unless
                /v0\.[67]/ =~ version
      end
    end
  end
end
