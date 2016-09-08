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
require 'terraform/apply_command'
require 'terraform/configurable'
require 'terraform/get_command'
require 'terraform/group'
require 'terraform/output_command'
require 'terraform/plan_command'
require 'terraform/validate_command'
require 'terraform/version'
require 'terraform/version_command'

module Kitchen
  module Provisioner
    # Terraform configuration applier
    class Terraform < Base
      SUPPORTED_VERSION = /v0.6/

      include ::Terraform::Configurable

      kitchen_provisioner_api_version 2

      plugin_version ::Terraform::VERSION

      required_config :apply_timeout do |_, value, provisioner|
        provisioner.coerce_apply_timeout value: value
      end

      default_config :apply_timeout, 600

      default_config :color, true

      default_config(:directory) { |provisioner| provisioner[:kitchen_root] }

      expand_path_for :directory

      default_config :plan do |provisioner|
        provisioner.instance_pathname filename: 'terraform.tfplan'
      end

      expand_path_for :plan

      default_config :state do |provisioner|
        provisioner.instance_pathname filename: 'terraform.tfstate'
      end

      expand_path_for :state

      required_config :variable_files do |_, value, provisioner|
        provisioner.coerce_variable_files value: value
      end

      default_config :variable_files, []

      expand_path_for :variable_files

      required_config :variables do |_, value, provisioner|
        provisioner.coerce_variables value: value
      end

      default_config :variables, {}

      def apply_execution_plan
        ::Terraform::ApplyCommand.execute \
          logger: logger, state: config[:state], target: config[:plan],
          color: config[:color], timeout: config[:apply_timeout]
      end

      def call(_state = nil)
        validate_configuration_files
        download_modules
        plan_constructive_execution
        apply_execution_plan
      end

      def coerce_apply_timeout(value:)
        config[:apply_timeout] = Integer value
      rescue ArgumentError, TypeError
        config_error attribute: :apply_timeout,
                     message: 'must be interpretable as an integer'
      end

      def coerce_color(value:)
        config[:color] = Boolean value
      rescue ArgumentError, TypeError
        config_error attribute: :color,
                     message: 'must be interpretable as a boolean'
      end

      def coerce_variable_files(value:)
        config[:variable_files] = Array value
      end

      def coerce_variables(value:)
        config[:variables] =
          if value.is_a?(Array) || value.is_a?(String)
            Hash[Array(value).map { |string| string.split '=' }]
          else
            Hash value
          end
      rescue ArgumentError, TypeError
        config_error attribute: :variables,
                     message: 'must be interpretable as a mapping of ' \
                                'Terraform variable assignments'
      end

      def download_modules
        ::Terraform::GetCommand.execute logger: logger,
                                        target: config[:directory]
      end

      def instance_pathname(filename:)
        File.join config[:kitchen_root], '.kitchen', 'kitchen-terraform',
                  instance.name, filename
      end

      def each_list_output(name:, &block)
        output(name: name).split(',').each(&block)
      end

      def output(name:)
        ::Terraform::OutputCommand
          .execute logger: logger, state: config[:state], target: name, &:chomp
      end

      def plan_constructive_execution
        ::Terraform::PlanCommand
          .execute destroy: false, logger: logger, out: config[:plan],
                   state: config[:state], target: config[:directory],
                   variables: config[:variables], color: config[:color],
                   variable_files: config[:variable_files]
      end

      def plan_destructive_execution
        ::Terraform::PlanCommand
          .execute destroy: true, logger: logger, out: config[:plan],
                   state: config[:state], target: config[:directory],
                   variables: config[:variables], color: config[:color],
                   variable_files: config[:variable_files]
      end

      def validate_configuration_files
        ::Terraform::ValidateCommand.execute logger: logger,
                                             target: config[:directory]
      end

      def validate_version
        ::Terraform::VersionCommand.execute logger: logger do |output|
          raise ::Terraform::UserError,
                "Terraform version must match #{SUPPORTED_VERSION}" unless
                  SUPPORTED_VERSION.match output
        end
      end
    end
  end
end
