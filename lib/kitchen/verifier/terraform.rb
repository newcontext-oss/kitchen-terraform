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
require 'terraform/client'
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
        config[:groups].resolve client: client do |group|
          self.group = group
          config[:attributes] = group.attributes
          info "Verifying #{group.description}"
          super
        end
      end

      private

      attr_accessor :group

      def client
        ::Terraform::Client.new config: provisioner, logger: debug_logger
      end

      def runner_options(transport, state = {})
        super.merge backend: group.backend, controls: group.controls,
                    host: group.hostname, port: group.port,
                    user: group.username
      end
    end
  end
end
