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

require 'terraform/client'
require_relative 'command_executor_examples'
require_relative 'configurable_context'

RSpec.shared_examples Terraform::Client do
  include_context '#provisioner'

  it_behaves_like Terraform::CommandExecutor

  describe '#apply_execution_plan' do
    let(:apply_command) { instance_double Terraform::ApplyCommand }

    let :apply_command_class do
      class_double(Terraform::ApplyCommand).as_stubbed_const
    end

    before do
      allow(apply_command_class).to receive(:new).with(
        color: provisioner_color, parallelism: 1234, state: provisioner_state,
        target: provisioner_plan
      ).and_return apply_command
    end

    after { described_instance.apply_execution_plan }

    subject { described_instance }

    it 'applies the execution plan with a timeout' do
      is_expected.to receive(:execute).with command: apply_command,
                                            timeout: provisioner_apply_timeout
    end
  end

  describe '#current_state' do
    let(:show_command) { instance_double Terraform::ShowCommand }

    let :show_command_class do
      class_double(Terraform::ShowCommand).as_stubbed_const
    end

    let(:value) { "\e[10mfoo\n" }

    before do
      allow(show_command_class).to receive(:new)
        .with(color: provisioner_color, target: provisioner_state)
        .and_return show_command

      allow(described_instance).to receive(:execute).with(command: show_command)
        .and_yield value
    end

    subject { described_instance.current_state }

    it 'returns the state output stripped of color and newlines' do
      is_expected.to eq 'foo'
    end
  end

  describe '#download_modules' do
    let(:get_command) { instance_double Terraform::GetCommand }

    let :get_command_class do
      class_double(Terraform::GetCommand).as_stubbed_const
    end

    before do
      allow(get_command_class).to receive(:new)
        .with(target: provisioner_directory).and_return get_command
    end

    after { described_instance.download_modules }

    subject { described_instance }

    it 'gets dependency modules' do
      is_expected.to receive(:execute).with command: get_command
    end
  end

  describe '#output_value(list: false, name:, &block)' do
    let(:output_command) { instance_double Terraform::OutputCommand }

    let :output_command_class do
      class_double(Terraform::OutputCommand).as_stubbed_const
    end

    let(:element_one) { instance_double Object }

    let(:element_two) { instance_double Object }

    let(:name) { instance_double Object }

    let(:value) { [element_one, element_two] }

    let(:version) { instance_double Object }

    before do
      allow(described_instance).to receive(:version).with(no_args)
        .and_return version

      allow(output_command_class).to receive(:new).with(
        list: list, state: provisioner_state, target: name, version: version
      ).and_return output_command

      allow(described_instance).to receive(:execute)
        .with(command: output_command).and_yield value
    end

    context 'when it is a list' do
      let(:list) { true }

      subject do
        lambda do |block|
          described_instance.output_value list: list, name: name, &block
        end
      end

      it 'yields each value element' do
        is_expected.to yield_successive_args element_one, element_two
      end
    end

    context 'when it is not a list' do
      let(:list) { false }

      subject { described_instance.output_value list: list, name: name }

      it('returns the named output value') { is_expected.to eq value }
    end
  end

  describe '#plan_execution(destroy:)' do
    let(:destroy) { instance_double Object }

    let(:plan_command) { instance_double Terraform::PlanCommand }

    let :plan_command_class do
      class_double(Terraform::PlanCommand).as_stubbed_const
    end

    before do
      allow(plan_command_class).to receive(:new).with(
        color: provisioner_color, destroy: destroy, out: provisioner_plan,
        parallelism: 1234, state: provisioner_state,
        target: provisioner_directory, variables: provisioner_variables,
        variable_files: provisioner_variable_files
      ).and_return plan_command
    end

    after { described_instance.plan_execution destroy: destroy }

    subject { described_instance }

    it 'plans an execution' do
      is_expected.to receive(:execute).with command: plan_command
    end
  end

  describe '#validate_configuration_files' do
    let(:validate_command) { instance_double Terraform::ValidateCommand }

    let :validate_command_class do
      class_double(Terraform::ValidateCommand).as_stubbed_const
    end

    before do
      allow(validate_command_class).to receive(:new)
        .with(target: provisioner_directory).and_return validate_command
    end

    after { described_instance.validate_configuration_files }

    subject { described_instance }

    it 'validates the configuration files' do
      is_expected.to receive(:execute).with command: validate_command
    end
  end

  describe '#each_output_name(&block)' do
    let(:output_command) { instance_double Terraform::OutputCommand }

    let :output_command_class do
      class_double(Terraform::OutputCommand).as_stubbed_const
    end

    let(:list) { false }

    let(:return_raw) { true }

    let(:test_json) do
      {
        contrived_hostnames: {
          sensitive: false,
          type: 'list',
          value: [
            'hostA.compute-1.amazonaws.com',
            'hostB.compute-1.amazonaws.com'
          ]
        },
        other_host_address: {
          sensitive: false,
          type: 'string',
          value: '123.123.123.123'
        }
      }.to_json
    end

    let(:version) { instance_double Object }

    let(:element_one) { 'contrived_hostnames' }

    let(:element_two) { 'other_host_address' }

    let(:output_names) { [element_one, element_two] }

    before do
      allow(described_instance).to receive(:version).with(no_args)
        .and_return version

      allow(output_command_class).to receive(:new).with(
        list: list, state: provisioner_state,
        return_raw: return_raw, version: version
      ).and_return output_command

      allow(described_instance).to receive(:execute)
        .with(command: output_command).and_yield test_json
    end

    subject do
      lambda do |block|
        described_instance.each_output_name(&block)
      end
    end

    it 'yields each output element' do
      is_expected.to yield_successive_args element_one, element_two
    end
  end

  describe '#version' do
    let(:version_command) { instance_double Terraform::VersionCommand }

    let :version_command_class do
      class_double(Terraform::VersionCommand).as_stubbed_const
    end

    let(:version) { "Terraform v12.345.6789\n" }

    before do
      allow(version_command_class).to receive(:new).with(no_args)
        .and_return version_command

      allow(described_instance).to receive(:execute)
        .with(command: version_command).and_yield version
    end

    subject { described_instance.version }

    it('returns the installed version') { is_expected.to eq 'v12.345.6789' }
  end
end
