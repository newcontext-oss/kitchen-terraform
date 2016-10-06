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
require 'kitchen/driver/terraform'
require 'kitchen/provisioner/terraform'
require 'kitchen/verifier/terraform'
require 'terraform/configurable'

::RSpec.shared_context 'client' do |client_type: :client|
  let(client_type) { instance_double ::Terraform::Client }

  before do
    allow(described_instance)
      .to receive(client_type).with(no_args).and_return send client_type
  end
end

::RSpec.shared_context 'instance' do
  let(:default_config) { { kitchen_root: kitchen_root } }

  let(:driver) { ::Kitchen::Driver::Terraform.new default_config }

  let :instance do
    ::Kitchen::Instance.new driver: driver, logger: logger, platform: platform,
                            provisioner: provisioner, state_file: object,
                            suite: suite, transport: transport,
                            verifier: verifier
  end

  let(:kitchen_root) { '/kitchen/root' }

  let(:logger) { ::Kitchen::Logger.new }

  let(:platform) { ::Kitchen::Platform.new name: 'platform' }

  let :provisioner do
    ::Kitchen::Provisioner::Terraform.new default_config
  end

  let(:suite) { ::Kitchen::Suite.new name: 'suite' }

  let(:transport) { ::Kitchen::Transport::Ssh.new }

  let(:verifier) { ::Kitchen::Verifier::Terraform.new default_config }

  before { instance }
end

::RSpec.shared_context 'limited_client' do
  include_context 'client', client_type: :limited_client
end

::RSpec.shared_context 'silent_client' do
  include_context 'client', client_type: :silent_client
end
