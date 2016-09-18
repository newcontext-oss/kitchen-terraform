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

RSpec.shared_context '#driver' do
  include_context '#instance'

  let(:driver) { instance_double Kitchen::Driver::Terraform }

  before { allow(instance).to receive(:driver).with(no_args).and_return driver }
end

RSpec.shared_context '#instance' do
  let(:instance) { instance_double Kitchen::Instance }

  let(:instance_name) { 'instance' }

  before do
    allow(described_instance).to receive(:instance).with(no_args)
      .and_return instance

    allow(instance).to receive(:name).with(no_args).and_return instance_name

    allow(instance).to receive(:to_str).with(no_args).and_return instance_name
  end
end

RSpec.shared_context '#logger' do
  let(:logger) { instance_double Kitchen::Logger }

  before do
    allow(described_instance).to receive(:logger).with(no_args)
      .and_return logger
  end
end

RSpec.shared_context '#provisioner' do
  include_context '#instance'

  let(:provisioner) { instance_double Kitchen::Provisioner::Terraform }

  let(:provisioner_apply_timeout) { instance_double Object }

  let(:provisioner_color) { instance_double Object }

  let(:provisioner_directory) { instance_double Object }

  let(:provisioner_plan) { instance_double Object }

  let(:provisioner_state) { instance_double Object }

  let(:provisioner_variables) { instance_double Object }

  let(:provisioner_variable_files) { instance_double Object }

  before do
    allow(instance).to receive(:provisioner).with(no_args)
      .and_return provisioner

    allow(provisioner).to receive(:[]).with(:apply_timeout)
      .and_return provisioner_apply_timeout

    allow(provisioner).to receive(:[]).with(:color).and_return provisioner_color

    allow(provisioner).to receive(:[]).with(:directory)
      .and_return provisioner_directory

    allow(provisioner).to receive(:[]).with(:plan).and_return provisioner_plan

    allow(provisioner).to receive(:[]).with(:state).and_return provisioner_state

    allow(provisioner).to receive(:[]).with(:variables)
      .and_return provisioner_variables

    allow(provisioner).to receive(:[]).with(:variable_files)
      .and_return provisioner_variable_files
  end
end

RSpec.shared_context '#transport' do
  include_context '#instance'

  let(:transport) { instance_double Kitchen::Transport::Ssh }

  before do
    allow(instance).to receive(:transport).with(no_args)
      .and_return transport
  end
end

RSpec.shared_context 'config' do
  let(:config) { { kitchen_root: kitchen_root } }

  let(:kitchen_root) { Dir.pwd }
end

RSpec.shared_context 'finalize_config! instance' do
  include_context '#instance'

  include_context 'config'

  after { described_instance.finalize_config! instance }
end
