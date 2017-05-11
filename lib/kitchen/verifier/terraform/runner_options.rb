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

require "kitchen/verifier/terraform"
require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "kitchen/verifier/terraform/configure_inspec_runner_backend"
require "kitchen/verifier/terraform/configure_inspec_runner_controls"
require "kitchen/verifier/terraform/configure_inspec_runner_host"
require "kitchen/verifier/terraform/configure_inspec_runner_port"
require "kitchen/verifier/terraform/configure_inspec_runner_user"

::Kitchen::Verifier::Terraform::RunnerOptions = lambda do |transport, state = {}, platform = nil, suite = nil|
  super(transport, state, platform, suite).tap do |options|
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend.call host: state.fetch(:host), options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost.call host: state.fetch(:host), options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort.call group: state.fetch(:group), options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser.call group: state.fetch(:group), options: options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
      .call client: silent_client, config: config, group: state.fetch(:group), terraform_state: provisioner[:state]
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerControls.call group: state.fetch(:group), options: options
  end
end
