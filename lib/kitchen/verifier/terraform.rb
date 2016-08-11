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
require 'kitchen/verifier/inspec'
require 'terraform/client_holder'
require 'terraform/configurable'
require 'terraform/group'
require 'terraform/inspec_runner'
require 'terraform/user_error'
require 'terraform/version'

module Kitchen
  module Verifier
    # Runs tests post-converge to confirm that instances in the Terraform state
    # are in an expected state
    class Terraform < Inspec
      extend ::Terraform::Configurable

      include ::Terraform::ClientHolder

      kitchen_verifier_api_version 2

      plugin_version ::Terraform::VERSION

      required_config :groups do |key, value, verifier|
        begin
          resolve key: key, value: value do |resolved_value|
            convert groups: resolved_value,
                    transport: verifier.instance.transport
          end
        rescue => error
          debug message: error
          config_error key: key, plugin: verifier,
                       message: 'must be a value than can be interpretted as ' \
                                  'a collection of group mappings'
        end
      end

      default_config :groups, []

      def call(state)
        each_group do |group|
          client.extract_list_output name: group.hostnames do |output|
            verify group: group, hostnames: output, state: state
          end
        end
      end

      def evaluate(exit_code:)
        return if exit_code.zero?

        raise ::Terraform::UserError, "Inspec Runner returns #{exit_code}"
      end

      def initialize_runner(group:, hostname:, state:)
        ::Terraform::InspecRunner
          .new runner_options_for_terraform group: group, hostname: hostname,
                                            state: state do |runner|
          resolve_attributes group: group do |name, value|
            runner.define_attribute name: name, value: value
          end
          runner.add targets: collect_tests
          yield runner
        end
      end

      def resolve_attributes(group:)
        group.each_attribute_pair do |method_name, variable_name|
          client.extract_output name: variable_name do |output|
            yield method_name, output
          end
        end
      end

      def runner_options_for_terraform(group:, hostname:, state:)
        runner_options(instance.transport, state)
          .merge controls: group.controls, host: hostname, port: group.port,
                 user: group.username
      end

      def verify(group:, hostnames:, state:)
        hostnames.each do |hostname|
          info "Verifying group: #{group}; hostname #{hostname}\n"
          initialize_runner group: group, hostname: hostname,
                            state: state do |runner|
            runner.verify_run verifier: self
          end
        end
      end

      private_class_method

      def self.convert(groups:, transport:, &block)
        Array(groups).each do |group|
          ::Terraform::Group.new(transport: transport, **Hash(group), &block)
        end
      rescue ArgumentError, TypeError
        raise UserError
      end

      private

      def each_group(&block)
        self.class.convert groups: config[:groups],
                           transport: instance.transport, &block
      end
    end
  end
end
