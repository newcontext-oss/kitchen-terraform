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

require 'kitchen/verifier/terraform'
require 'support/terraform/configurable_context'
require 'support/terraform/configurable_examples'
require 'support/terraform/groups_config_examples'
require 'terraform/group'

RSpec.describe Kitchen::Verifier::Terraform do
  include_context 'config'

  let(:described_instance) { described_class.new config }

  let(:inspec_runner_options) { instance_double Hash }

  before do
    allow(described_instance).to receive(:inspec_runner_options).with(no_args)
      .and_return inspec_runner_options
  end

  it_behaves_like Terraform::Configurable

  it_behaves_like Terraform::GroupsConfig

  describe '#add_targets(runner:)' do
    let(:runner) { instance_double Terraform::InspecRunner }

    let(:test) { instance_double Object }

    before do
      allow(described_instance).to receive(:collect_tests).with(no_args)
        .and_return [test]
    end

    after { described_instance.add_targets runner: runner }

    subject { runner }

    it 'adds its tests to the runner' do
      is_expected.to receive(:add_target).with test
    end
  end

  describe '#call(state)' do
    include_context '#transport'

    let(:evaluate) { receive(:evaluate).with verifier: described_instance }

    let(:group) { instance_double Terraform::Group }

    let(:runner_key) { instance_double Object }

    let(:runner_options) { { runner_key => runner_value } }

    let(:runner_value) { instance_double Object }

    let :set_options do
      receive(:inspec_runner_options=).with runner_options
    end

    let(:state) { instance_double Object }

    before do
      allow(described_instance).to receive(:runner_options)
        .with(transport, state).and_return runner_options

      allow(config).to receive(:[]).with(:groups).and_return [group]

      allow(group).to evaluate
    end

    after { described_instance.call state }

    describe 'setting options' do
      subject { described_instance }

      it 'uses logic of Kitchen::Verifier::Inspec' do
        is_expected.to set_options
      end
    end

    describe 'evaluating tests' do
      subject { group }

      it('each group is evaluated') { is_expected.to evaluate }
    end
  end

  describe '#execute' do
    let(:inspec_runner) { instance_double Terraform::InspecRunner }

    let :inspec_runner_class do
      class_double(Terraform::InspecRunner).as_stubbed_const
    end

    before do
      allow(inspec_runner_class).to receive(:new).with(inspec_runner_options)
        .and_return inspec_runner
    end

    after { described_instance.execute }

    subject { inspec_runner }

    it 'evaluates the configuration' do
      is_expected.to receive(:evaluate).with verifier: described_instance
    end
  end

  describe '#merge(options:)' do
    let(:options) { instance_double Object }

    after { described_instance.merge options: options }

    subject { inspec_runner_options }

    it 'prioritizes the provided options' do
      is_expected.to receive(:merge!).with options
    end
  end

  describe '#resolve_attributes(group:)' do
    include_context '#driver'

    let(:group) { instance_double Terraform::Group }

    let(:key) { instance_double Object }

    let(:output_name) { instance_double Object }

    let(:output_names) { instance_double Array }

    let(:output_value) { instance_double Object }

    before do
      allow(group).to receive(:each_attribute).with(no_args)
        .and_yield key, output_name

      # allow(driver).to receive(:each).with(no_args)
      #   .and_yield output_name

      allow(group).to receive(:store_output_names).with(name: output_name)

      allow(group).to receive(:merge_attributes).with(no_args)

      allow(driver).to receive(:output_value).with(name: output_name)
        .and_return output_value

      allow(output_names).to receive(:each).with(no_args)
        .and_yield output_name

      allow(driver).to receive(:list_output_names).with(no_args)
        .and_return output_names
    end

    after { described_instance.resolve_attributes group: group }

    subject { group }

    it 'updates each attribute with the resolved output value' do
      is_expected.to receive(:store_attribute).with key: key,
                                                    value: output_value
    end
  end

  describe '#resolve_hostnames(group:, &block)' do
    include_context '#driver'

    let(:group) { instance_double Terraform::Group }

    let(:hostnames) { instance_double Object }

    before do
      allow(group).to receive(:hostnames).with(no_args).and_return hostnames
    end

    after { described_instance.resolve_hostnames group: group }

    subject { driver }

    it 'yields each hostname' do
      is_expected.to receive(:output_value).with list: true, name: hostnames
    end
  end

  describe '#verify(exit_code:)' do
    subject { proc { described_instance.verify exit_code: exit_code } }

    context 'when the exit code is 0' do
      let(:exit_code) { 0 }

      it('does not raise an error') { is_expected.to_not raise_error }
    end

    context 'when the exit code is not 0' do
      let(:exit_code) { 1 }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure
      end
    end
  end
end
