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
require 'terraform/client_holder'
require 'terraform/version'

module Kitchen
  module Provisioner
    # Terraform configuration applier
    class Terraform < Base
      include ::Terraform::ClientHolder

      kitchen_provisioner_api_version 2

      plugin_version ::Terraform::VERSION

      required_config :apply_timeout do |key, value, provisioner|
        resolve key: key, value: value do |resolved_value|
          begin
            Integer resolved_value
          rescue ArgumentError, TypeError
            config_error key: key, provisioner: provisioner,
                         message: 'Must be a value that can be interpretted ' \
                                    'as an integer'
          end
        end
      end

      default_config :apply_timeout, 600

      required_config :directory do |key, value, provisioner|
        resolve key: key, value: value do |resolved_value|
          next if (File.directory? String resolved_value) ||
                  resolved_value.is_a?(Proc)

          config_error key: key, provisioner: provisioner,
                       message: 'Must be a value that can be interpretted as ' \
                                  'an existing directory pathname'
        end
      end

      default_config(:directory) { |provisioner| provisioner[:kitchen_root] }

      expand_path_for :directory

      required_config :variable_files do |key, value, provisioner|
        resolve key: key, value: value do |resolved_value|
          next unless
            Array(resolved_value).any? { |file| !File.file? String file }

          config_error key: key, provisioner: provisioner,
                       message: 'Must be a value that can be interpretted as ' \
                                  'a list of existing file pathnames'
        end
      end

      default_config :variable_files, []

      expand_path_for :variable_files

      required_config :variables do |key, value, provisioner|
        resolve key: key, value: value do |resolved_value|
          next unless Array(resolved_value).any?(&method(:invalid_variable))

          config_error key: key, provisioner: provisioner,
                       message: 'Must be a value that can be interpretted as ' \
                                  'a list of variable assignments'
        end
      end

      default_config :variables, []

      def call(_state = nil)
        client.validate_configuration_files
        client.download_modules
        client.plan_execution
        client.apply_execution_plan
      end

      private_class_method

      def self.config_error(key:, provisioner:, message:)
        raise UserError,
              "#{self}#{provisioner.instance.to_str}#config[:#{key}] " \
                "#{message}"
      end

      def self.resolve(key:, value:)
        yield value || defaults[key]
      end

      def self.invalid_variable(variable)
        !(/^\s*[\w|-]+={1}\S+\s*$/ =~ String(variable))
      end
    end
  end
end
