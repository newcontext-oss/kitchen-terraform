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

require "kitchen"
require "kitchen/config/groups"
require "kitchen/verifier/inspec"
require "terraform/configurable"

# Runs tests post-converge to confirm that instances in the Terraform state are in an expected state
class ::Kitchen::Verifier::Terraform < ::Kitchen::Verifier::Inspec
  ::Kitchen::Config::Groups.call plugin_class: self

  kitchen_verifier_api_version 2

  include ::Terraform::Configurable

  def call(state)
    config.fetch(:groups).each do |group|
      state.store :group, group
      ::Kitchen::Verifier::Terraform::EnumerateGroupHosts.call client: silent_client, group: group do |host:|
        state.store :host, host
        info "Verifying '#{host}' of group '#{group.fetch :name}'"
        super state
      end
    end
  rescue ::Kitchen::StandardError, ::SystemCallError => error
    raise ::Kitchen::ActionFailed, error.message
  end

  private

  def configure_inspec_runner(group:, host:, options:)
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend.call host: host, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost.call host: host, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort.call group: group, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser.call group: group, options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
      .call client: silent_client, config: config, group: group, terraform_state: provisioner[:state]
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerControls.call group: group, options: options
  end

  def runner_options(transport, state = {}, platform = nil, suite = nil)
    super(transport, state, platform, suite).tap do |options|
      configure_inspec_runner group: state.fetch(:group), host: state.fetch(:host), options: options
    end
  end
end

require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "kitchen/verifier/terraform/configure_inspec_runner_backend"
require "kitchen/verifier/terraform/configure_inspec_runner_controls"
require "kitchen/verifier/terraform/configure_inspec_runner_host"
require "kitchen/verifier/terraform/configure_inspec_runner_port"
require "kitchen/verifier/terraform/configure_inspec_runner_user"
require "kitchen/verifier/terraform/enumerate_group_hosts"
