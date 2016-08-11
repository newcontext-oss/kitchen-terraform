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
require 'terraform/configurable'
require 'terraform/version'

module Kitchen
  module Verifier
    # Runs tests post-converge to confirm that instances in the Terraform state
    # are in an expected state
    class Terraform < Inspec
      include ::Terraform::Configurable

      kitchen_verifier_api_version 2

      plugin_version ::Terraform::VERSION

      required_config :groups do |_, value, verifier|
        verifier.coerce_groups value: value
      end

      default_config :groups, []

      def call(state)
        config[:groups].each do |group|
          group.verify_each_host options: runner_options(transport, state)
        end
      end

      def coerce_groups(value:)
        config[:groups] = Array(value).map do |raw_group|
          ::Terraform::Group.new value: raw_group, verifier: self
        end
      rescue UserError
        config_error attribute: 'groups',
                     expected: 'a collection of group mappings'
      end

      def evaluate(exit_code:)
        raise InstanceFailure, "Inspec Runner returns #{exit_code}" unless
          exit_code.zero?
      end

      def populate(runner:)
        collect_tests.each { |test| runner.add target: test }
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
