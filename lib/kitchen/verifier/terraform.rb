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

      def add_targets(runner:)
        collect_tests.each { |test| runner.add target: test }
      end

      def call(state)
        each_group_host_runner state: state do |runner|
          info "Verifying host '#{runner.conf[:host]}' of group " \
                 "'#{runner.conf[:name]}'"
          runner.evaluate verifier: self
        end
      end

      def verify(exit_code:)
        raise InstanceFailure, "Inspec Runner returns #{exit_code}" unless
          exit_code.zero?
      end

      private

      def load_needed_dependencies!
        require 'terraform/inspec_runner'
      end
    end
  end
end
