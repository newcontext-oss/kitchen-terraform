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
require 'terraform/inspec_runner'
require 'terraform/version'

module Kitchen
  module Verifier
    # Runs tests post-converge to confirm that instances in the Terraform state
    # are in an expected state
    class Terraform < Inspec
      include ::Terraform::ClientHolder

      kitchen_verifier_api_version 2

      plugin_version ::Terraform::VERSION

      def attributes(group:)
        group.fetch(:attributes) { {} }
      end

      def call(state)
        groups.each do |group|
          client.extract_list_output name: group.fetch(:hostnames) do |output|
            verify group: group, hostnames: output, state: state
          end
        end
      rescue => error
        raise ActionFailed, error.message, error.backtrace
      end

      def controls(group:)
        group.fetch(:controls) { [] }
      end

      def evaluate(exit_code:)
        raise "Inspec Runner returns #{exit_code}" unless 0 == exit_code
      end

      def groups
        config.fetch(:groups) { [] }
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

      def port(group:)
        # FIXME: apply the principle of least knowledge
        group.fetch(:port) { instance.transport.send(:config).fetch :port }
      end

      def resolve_attributes(group:)
        attributes(group: group).each_pair do |method_name, variable_name|
          client.extract_output name: variable_name do |output|
            yield method_name, output
          end
        end
      end

      def runner_options_for_terraform(group:, hostname:, state:)
        runner_options(instance.transport, state)
          .merge controls: controls(group: group), host: hostname,
                 port: port(group: group), user: username(group: group)
      end

      def username(group:)
        # FIXME: apply the principle of least knowledge
        group.fetch :username do
          instance.transport.send(:config).fetch :username
        end
      end

      def verify(group:, hostnames:, state:)
        hostnames.each do |hostname|
          info "Verifying group: #{group.fetch :name}; hostname #{hostname}\n"
          initialize_runner group: group, hostname: hostname,
                            state: state do |runner|
            runner.verify_run verifier: self
          end
        end
      end
    end
  end
end
