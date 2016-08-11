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

require 'inspec'
require 'kitchen/verifier/terraform'
require 'support/terraform/client_holder_context'
require 'support/terraform/client_holder_examples'
require 'support/terraform/configurable_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Verifier::Terraform do
  let(:config) { required_config.merge optional_config }

  let(:described_instance) { described_class.new config }

  let(:group) { instance_double Terraform::Group }

  let(:optional_config) { {} }

  let(:required_config) { { kitchen_root: '<kitchen_root>' } }

  let(:state) { {} }

  let(:transport) { instance_double Object }

  it_behaves_like Terraform::ClientHolder

  it_behaves_like Terraform::Configurable, key: :groups,
                                           criteria: 'interpretable as a ' \
                                                       'collection of group' \
                                                       'mappings ' do
    let(:default) { be_empty }

    let(:error_message) { /collection of group mappings/ }

    let(:invalid_value) { ['not a group mapping'] }

    let :valid_value do
      [{ hostnames: [], name: 'foo', port: 1, username: 'username' }]
    end

    before do
      allow(instance).to receive(:transport).with(no_args).and_return transport
    end
  end

  it_behaves_like 'versions are set'

  describe '#call(state)' do
    include_context '#client'

    let(:call_method) { described_instance.call state }

    let(:groups) { instance_double Object }

    let(:hostnames) { instance_double Object }

    let(:instance) { instance_double Kitchen::Instance }

    let(:optional_config) { { groups: groups } }

    before do
      allow(group).to receive(:hostnames).with(no_args).and_return hostnames

      allow(described_instance).to receive(:instance).with(no_args)
        .and_return instance

      allow(instance).to receive(:transport).with(no_args).and_return transport

      allow(described_class).to receive(:convert)
        .with(groups: groups, transport: transport).and_yield group
    end

    context 'when the hostnames list output can be extracted' do
      let(:output) { instance_double Object }

      before do
        allow(client).to receive(:extract_list_output).with(name: hostnames)
          .and_yield output
      end

      after { call_method }

      subject { described_instance }

      it 'verifies the hosts of each group' do
        is_expected.to receive(:verify).with group: group, hostnames: output,
                                             state: state
      end
    end

    context 'when the hostnames list output can not be extracted' do
      before do
        allow(client).to receive(:extract_list_output).with(name: hostnames)
          .and_raise Terraform::Error
      end

      subject { proc { call_method } }

      it('raises an error') { is_expected.to raise_error Kitchen::ActionFailed }
    end
  end

  describe '#evaluate(exit_code:)' do
    subject { proc { described_instance.evaluate exit_code: exit_code } }

    context 'when the exit code is 0' do
      let(:exit_code) { 0 }

      it('does not raise an error') { is_expected.to_not raise_error }
    end

    context 'when the exit code is not 0' do
      let(:exit_code) { 1 }

      it('raises an error') { is_expected.to raise_error Terraform::Error }
    end
  end

  describe '#initialize_runner(group:, hostname:, state:)' do
    let(:group) { instance_double Object }

    let(:hostname) { instance_double Object }

    let(:inspec_runner) { instance_double Terraform::InspecRunner }

    let :inspec_runner_class do
      class_double(Terraform::InspecRunner).as_stubbed_const
    end

    let(:name) { instance_double Object }

    let(:options) { instance_double Object }

    let(:state) { instance_double Object }

    let(:value) { instance_double Object }

    before do
      allow(described_instance).to receive(:runner_options_for_terraform)
        .with(group: group, hostname: hostname, state: state).and_return options

      allow(inspec_runner_class).to receive(:new).with(options)
        .and_yield inspec_runner

      allow(described_instance).to receive(:resolve_attributes)
        .with(group: group).and_yield name, value

      allow(inspec_runner).to receive(:define_attribute).with name: name,
                                                              value: value

      allow(described_instance).to receive(:collect_tests).and_return []

      allow(inspec_runner).to receive(:add).with targets: kind_of(Array)
    end

    subject do
      lambda do |block|
        described_instance.initialize_runner group: group, hostname: hostname,
                                             state: state, &block
      end
    end

    it 'yields an InspecRunner for the group host' do
      is_expected.to yield_with_args inspec_runner
    end
  end

  describe '#resolve_attributes(group:)' do
    include_context '#client'

    let(:method_name) { instance_double Object }

    let(:output) { instance_double Object }

    let(:variable_name) { instance_double Object }

    before do
      allow(group).to receive(:each_attribute_pair).with(no_args)
        .and_yield method_name, variable_name

      allow(client).to receive(:extract_output).with(name: variable_name)
        .and_yield output
    end

    subject do
      ->(block) { described_instance.resolve_attributes group: group, &block }
    end

    it 'extracts an output value for each attribute pair in the group' do
      is_expected.to yield_with_args method_name, output
    end
  end

  describe '#runner_options_for_terraform(group:, hostname:, state:)' do
    let(:controls) { instance_double Object }

    let(:instance) { instance_double Kitchen::Instance }

    let(:hostname) { instance_double Object }

    let(:port) { instance_double Object }

    let(:username) { instance_double Object }

    before do
      allow(described_instance).to receive(:instance).with(no_args)
        .and_return instance

      allow(instance).to receive(:transport).with(no_args).and_return transport

      allow(described_instance).to receive(:runner_options)
        .with(transport, state).and_return({})

      allow(group).to receive(:controls).with(no_args).and_return controls

      allow(group).to receive(:port).with(no_args).and_return port

      allow(group).to receive(:username).with(no_args).and_return username
    end

    subject do
      described_instance.runner_options_for_terraform group: group,
                                                      hostname: hostname,
                                                      state: state
    end

    it 'adds the group controls, host, port and user to the runner options' do
      is_expected.to include controls: controls, host: hostname, port: port,
                             user: username
    end
  end

  describe '#verify(group:, hostnames:, state:)' do
    let(:group) { { name: instance_double(Object) } }

    let(:hostname) { instance_double Object }

    let(:runner) { instance_double Terraform::InspecRunner }

    before do
      allow(described_instance).to receive(:initialize_runner)
        .with(group: group, hostname: hostname, state: state).and_yield runner

      allow(runner).to receive(:verify_run).with verifier: described_instance
    end

    after do
      described_instance.verify group: group, hostnames: [hostname],
                                state: state
    end

    subject { runner }

    it 'verifies the Inspec run' do
      is_expected.to receive(:verify_run).with verifier: described_instance
    end
  end
end
