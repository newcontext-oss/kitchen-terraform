# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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
    class Terraform < ::Kitchen::Verifier::Inspec
      extend ::Terraform::GroupsConfig

      include ::Terraform::Configurable

      kitchen_verifier_api_version 2

      def call(state)
        resolve_groups do |group|
          self.group = group
          config[:attributes] = {
            'terraform_state' => provisioner[:state].to_path
          }.merge group.attributes
          info "Verifying #{group.description}"
          super
        end
      rescue ::Kitchen::StandardError, ::SystemCallError => error
        raise ::Kitchen::ActionFailed, error.message
      end

      private

      attr_accessor :group

      def configure_backend(options:)
        /(local)host/.match group.hostname do |match|
          options.merge! 'backend' => match[1]
        end
      end

      def resolve_groups(&block)
        config[:groups]
          .each { |group| group.resolve client: silent_client, &block }
      end

      def runner_options(transport, state = {}, platform = nil, suite = nil)
        super.tap do |options|
          options.merge! controls: group.controls, 'host' => group.hostname,
                         'port' => group.port, 'user' => group.username
          configure_backend options: options
        end
      end
    end
  end
end
