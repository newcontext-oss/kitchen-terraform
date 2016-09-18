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

RSpec.describe Kitchen::Verifier::Terraform do
  include_context 'config'

  let(:described_instance) { described_class.new config }

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
      is_expected.to receive(:add).with target: test
    end
  end

  describe '#call(state)' do
    let(:conf) { { host: host, name: name } }

    let(:host) { instance_double Object }

    let(:name) { instance_double Object }

    let(:runner) { instance_double Terraform::InspecRunner }

    let(:state) { instance_double Object }

    before do
      allow(described_instance).to receive(:each_group_host_runner)
        .with(state: state).and_yield runner

      allow(runner).to receive(:conf).with(no_args).and_return conf

      allow(described_instance).to receive(:info)
        .with "Verifying host '#{host}' of group '#{name}'"
    end

    after { described_instance.call state }

    subject { runner }

    it 'evaluates each host of each group with the runner' do
      is_expected.to receive(:evaluate).with verifier: described_instance
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
