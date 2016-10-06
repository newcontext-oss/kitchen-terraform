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

require 'kitchen/verifier/inspec'
require 'terraform/configurable'
require 'terraform/groups_config'

module Kitchen
  module Verifier
    # Runs tests post-converge to confirm that instances in the Terraform state
    # are in an expected state
    class Terraform < Inspec
      include ::Terraform::Configurable

      include ::Terraform::GroupsConfig

      kitchen_verifier_api_version 2

      def call(state)
        verify_groups options: runner_options(transport, state)
      end

      private

      def add_targets(runner:)
        collect_tests.each { |test| runner.add_target test }
      end

      def execute(group:, options:)
        options.merge! group.options
        ::Inspec::Runner.new(options).tap do |runner|
          add_targets runner: runner
          validate exit_code: runner.run
        end
      end

      def execute_local(group:, options:)
        options[:backend] = 'local'
        info "Verifying group '#{group.name}'"
        execute group: group, options: options
      end

      def execute_remote(group:, options:)
        driver.output_value list: true, name: group.hostnames do |hostname|
          options[:host] = hostname
          info "Verifying host '#{hostname}' of group '#{group.name}'"
          execute group: group, options: options
        end
      end

      def resolve_attributes(group:)
        driver.each_output_name do |output_name|
          group.store_attribute key: output_name, value: output_name
        end
        group.each_attribute do |key, output_name|
          group.store_attribute key: key.to_s,
                                value: driver.output_value(name: output_name)
        end
      end

      def validate(exit_code:)
        return if exit_code.zero?

        raise ::Kitchen::InstanceFailure, "Inspec Runner returns #{exit_code}"
      end

      def verify(group:, options:)
        resolve_attributes group: group
        group.if_local { return execute_local group: group, options: options }
        execute_remote group: group, options: options
      end

      def verify_groups(options:)
        config[:groups]
          .each { |group| verify group: group, options: options.dup }
      end
    end
  end
end
