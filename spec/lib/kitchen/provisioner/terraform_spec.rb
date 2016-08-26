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

require 'kitchen/provisioner/terraform'
require 'terraform/error'
require 'support/terraform/configurable_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Provisioner::Terraform do
  include_context 'config'

  include_context '#instance'

  include_context '#logger'

  let(:described_instance) { described_class.new config }

  shared_context 'command' do
    let(:apply_timeout) { instance_double Object }

    let(:directory) { instance_double Object }

    let(:plan) { instance_double Object }

    let(:state) { instance_double Object }

    let(:variable_files) { instance_double Object }

    let(:variables) { instance_double Object }

    before do
      config.merge! apply_timeout: apply_timeout, directory: directory,
                    plan: plan, state: state, variable_files: variable_files,
                    variables: variables
    end
  end

  it_behaves_like Terraform::Configurable

  it_behaves_like 'versions are set'

  describe '#apply_execution_plan' do
    include_context 'command'

    after { described_instance.apply_execution_plan }

    subject do
      class_double(Terraform::ApplyCommand).as_stubbed_const
    end

    it 'executes the apply command with the existing plan' do
      is_expected.to receive(:execute).with logger: logger, state: state,
                                            target: plan, timeout: apply_timeout
    end
  end

  describe '#call(_state = nil)' do
    let :allow_apply do
      allow(described_instance).to receive(:validate_configuration_files)
        .with no_args

      allow(described_instance).to receive(:download_modules).with no_args

      allow(described_instance).to receive(:plan_constructive_execution)
        .with no_args

      allow(described_instance).to receive(:apply_execution_plan).with no_args
    end

    let(:call_method) { described_instance.call }

    context 'when all Terraform commands are successful' do
      before { allow_apply }

      after { call_method }

      subject { described_instance }

      it 'validates the configuration files' do
        is_expected.to receive(:validate_configuration_files).with no_args
      end

      it 'downloads any dependency modules' do
        is_expected.to receive(:download_modules).with no_args
      end

      it 'plans the constructive execution' do
        is_expected.to receive(:plan_constructive_execution).with no_args
      end

      it 'applys the constructive execution plan' do
        is_expected.to receive(:apply_execution_plan).with no_args
      end
    end

    context 'when all Terraform commands are not successful' do
      before { allow_apply.and_raise Terraform::UserError }

      subject { proc { call_method } }

      it 'raises an action failed error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end
  end

  describe '#coerce_apply_timeout(value:)' do
    let(:call_method) { described_instance.coerce_apply_timeout value: value }

    context 'when the value can be coerced to be an integer' do
      let(:value) { 1 }

      before { call_method }

      subject { described_instance[:apply_timeout] }

      it('updates the config assignment') { is_expected.to eq value }
    end

    context 'when the value can not be coerced to be an integer' do
      let(:value) { 'a' }

      subject { proc { call_method } }

      it 'raises a user error' do
        is_expected.to raise_error Terraform::UserError, /an integer/
      end
    end
  end

  describe '#coerce_variable_files(value:)' do
    let(:value) { instance_double Object }

    before { described_instance.coerce_variable_files value: value }

    subject { described_instance[:variable_files] }

    it('updates the config assignment') { is_expected.to eq [value] }
  end

  describe '#coerce_variables(value:)' do
    let(:call_method) { described_instance.coerce_variables value: value }

    context 'when the value can be coerced to be a mapping' do
      let(:value) { 'foo=bar' }

      before { call_method }

      subject { described_instance[:variables] }

      it('updates the config assignment') { is_expected.to eq 'foo' => 'bar' }
    end

    context 'when the value can not be coerced to be a mapping' do
      let(:value) { 1 }

      subject { proc { call_method } }

      it 'raises a user error' do
        is_expected.to raise_error Terraform::UserError,
                                   /mapping of Terraform variable assignments/
      end
    end
  end

  describe '#download_modules' do
    include_context 'command'

    after { described_instance.download_modules }

    subject { class_double(Terraform::GetCommand).as_stubbed_const }

    it 'downloads any dependency modules' do
      is_expected.to receive(:execute).with logger: logger, target: directory
    end
  end

  describe '#finalize_config!(instance)' do
    include_context '#finalize_config!(instance)'

    before do
      allow(instance).to receive(:name).with(no_args).and_return 'instance'
    end

    describe '[:apply_timeout]' do
      subject { described_instance[:apply_timeout] }

      it('defaults to 600 seconds') { is_expected.to eq 600 }
    end

    describe '[:directory]' do
      subject { described_instance[:directory] }

      it('defaults to the Kitchen root') { is_expected.to eq kitchen_root }
    end

    describe '[:plan]' do
      subject { described_instance[:plan] }

      it 'defaults to an instance pathname' do
        is_expected.to match %r{instance/terraform\.tfplan}
      end
    end

    describe '[:state]' do
      subject { described_instance[:state] }

      it 'defaults to an instance pathname' do
        is_expected.to match %r{instance/terraform\.tfstate}
      end
    end

    describe '[:variable_files]' do
      subject { described_instance[:variable_files] }

      it('defaults to an empty collection') { is_expected.to eq [] }
    end

    describe '[:variables]' do
      subject { described_instance[:variables] }

      it('defaults to an empty mapping') { is_expected.to eq({}) }
    end
  end

  describe '#instance_pathname(filename:)' do
    let(:filename) { 'foo' }

    subject { described_instance.instance_pathname filename: filename }

    it 'returns a pathname under the hidden instance directory' do
      is_expected
        .to eq "#{kitchen_root}/.kitchen/kitchen-terraform/instance/#{filename}"
    end
  end

  describe '#each_list_output(name:, &block)' do
    let(:name) { instance_double Object }

    before do
      allow(described_instance).to receive(:output).with(name: name)
        .and_return 'foo,bar'
    end

    subject do
      ->(block) { described_instance.each_list_output name: name, &block }
    end

    it 'yields each element of a CSV list output' do
      is_expected.to yield_successive_args 'foo', 'bar'
    end
  end

  describe '#output(name:)' do
    include_context 'command'

    let(:name) { instance_double Object }

    let(:output) { "foo\n" }

    let :output_command_class do
      class_double(Terraform::OutputCommand).as_stubbed_const
    end

    before do
      allow(output_command_class).to receive(:execute)
        .with(logger: logger, state: state, target: name).and_yield output
    end

    subject { described_instance.output name: name }

    it('returns the output value') { is_expected.to eq 'foo' }
  end

  describe '#plan_destructive_execution' do
    include_context 'command'

    after { described_instance.plan_destructive_execution }

    subject { class_double(Terraform::PlanCommand).as_stubbed_const }

    it 'plans a destructive execution' do
      is_expected.to receive(:execute)
        .with destroy: true, logger: logger, out: plan, state: state,
              target: directory, variables: variables,
              variable_files: variable_files
    end
  end

  describe '#plan_constructive_execution' do
    include_context 'command'

    after { described_instance.plan_constructive_execution }

    subject { class_double(Terraform::PlanCommand).as_stubbed_const }

    it 'plans a constructive execution' do
      is_expected.to receive(:execute)
        .with destroy: false, logger: logger, out: plan, state: state,
              target: directory, variables: variables,
              variable_files: variable_files
    end
  end

  describe '#validate_configuration_files' do
    include_context 'command'

    after { described_instance.validate_configuration_files }

    subject { class_double(Terraform::ValidateCommand).as_stubbed_const }

    it 'validates the configuration files' do
      is_expected.to receive(:execute).with logger: logger, target: directory
    end
  end

  describe '#validate_version' do
    include_context 'command'

    let :validate_command_class do
      class_double(Terraform::VersionCommand).as_stubbed_const
    end

    before do
      allow(validate_command_class).to receive(:execute).with(logger: logger)
        .and_yield output
    end

    subject { proc { described_instance.validate_version } }

    context 'when the installed version of Terraform is supported' do
      let(:output) { 'v0.6' }

      it('raises no error') { is_expected.to_not raise_error }
    end

    context 'when the installed version of Terraform is not supported' do
      let(:output) { 'v0.7' }

      it 'raises a user error' do
        is_expected.to raise_error Terraform::UserError, /version must match/
      end
    end
  end
end
