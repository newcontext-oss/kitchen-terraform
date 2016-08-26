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
require 'support/terraform/configurable_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Verifier::Terraform do
  include_context 'config'

  let(:described_instance) { described_class.new config }

  it_behaves_like Terraform::Configurable

  it_behaves_like 'versions are set'

  describe '#call(state)' do
    include_context '#provisioner'

    include_context '#transport'

    let :allow_verify do
      allow(group).to receive(:verify_each_host).with options: runner_options
    end

    let(:group) { instance_double Terraform::Group }

    let(:runner_options) { instance_double Object }

    let(:state) { instance_double Object }

    before do
      config.store :groups, [group]

      allow(described_instance).to receive(:runner_options)
        .with(transport, state).and_return runner_options
    end

    subject { proc { described_instance.call state } }

    context 'when the groups are successfully verified' do
      before { allow_verify }

      it('raises no error') { is_expected.to_not raise_error }
    end

    context 'when the groups are not successfully verified' do
      before { allow_verify.and_raise Terraform::Error }

      it 'raises an action failed error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end
  end

  describe '#coerce_groups(value:)' do
    include_context '#transport'

    let :allow_new_group do
      allow(group_class).to receive(:new)
        .with(value: raw_group, verifier: described_instance)
    end

    let(:call_method) { described_instance.coerce_groups value: value }

    let(:group_class) { class_double(Terraform::Group).as_stubbed_const }

    let(:raw_group) { instance_double Object }

    let(:value) { [raw_group] }

    context 'when the value can be coerced to be a group' do
      let(:group) { instance_double Object }

      before do
        allow_new_group.and_return group
        call_method
      end

      subject { described_instance[:groups] }

      it('updates the config assignment') { is_expected.to eq [group] }
    end

    context 'when the value can not be coerced to be a group' do
      before { allow_new_group.and_raise Terraform::UserError }

      subject { proc { call_method } }

      it 'raises a user error' do
        is_expected.to raise_error Terraform::UserError,
                                   /collection of group mappings/
      end
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

      it 'raises a user error' do
        is_expected.to raise_error Terraform::UserError
      end
    end
  end

  describe '#finalize_config!(instance)' do
    include_context '#finalize_config!(instance)'

    describe '[:groups]' do
      subject { described_instance[:groups] }

      it('defaults to an empty collection') { is_expected.to eq [] }
    end
  end

  describe '#populate(runner:)' do
    let(:runner) { instance_double Terraform::InspecRunner }

    let(:test) { instance_double Object }

    before do
      allow(described_instance).to receive(:collect_tests).with(no_args)
        .and_return [test]
    end

    after { described_instance.populate runner: runner }

    subject { runner }

    it 'adds the tests to the runner' do
      is_expected.to receive(:add).with target: test
    end
  end
end
