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
require 'support/terraform/configurable_context'

::RSpec.describe ::Terraform::Client do
  include_context 'instance'

  let :described_instance do
    described_class.new config: provisioner, logger: ::Kitchen::Logger.new
  end

  shared_context '#output_parser' do
    let(:version) { '0.7' }

    before do
      allow(described_instance).to receive(:version).with(no_args)
        .and_return ::Terraform::Version.new value: version

      allow(described_instance)
        .to receive(:execute).with(command: kind_of(::Terraform::OutputCommand))
        .and_yield output_value
    end
  end

  shared_examples '#apply' do
    let(:apply_shell_out) { instance_double ::Terraform::ShellOut }

    before do
      provisioner[:apply_timeout] = 1234

      allow(::Terraform::ShellOut).to receive(:new).with(
        command: kind_of(::Terraform::ApplyCommand), logger: duck_type(:<<),
        timeout: 1234
      ).and_return apply_shell_out

      allow(apply_shell_out).to receive(:execute).with no_args
    end

    shared_examples '#execute' do |command|
      let(:shell_out) { instance_double ::Terraform::ShellOut }

      before do
        allow(described_instance)
          .to receive(:execute).with(command: kind_of(::Terraform::Command))

        allow(described_instance).to receive(:execute)
          .with(command: kind_of(command_class)).and_call_original

        allow(::Terraform::ShellOut).to receive(:new)
          .with(command: kind_of(command_class), logger: duck_type(:<<))
          .and_return shell_out
      end

      subject { shell_out }

      it "a #{command} command is executed" do
        is_expected.to receive(:execute).with no_args
      end
    end

    it_behaves_like '#execute', 'validate' do
      let(:command_class) { ::Terraform::ValidateCommand }
    end

    it_behaves_like '#execute', 'get' do
      let(:command_class) { ::Terraform::GetCommand }
    end

    it_behaves_like '#execute', 'plan' do
      let(:command_class) { plan_command_class }
    end

    describe 'the apply command' do
      before do
        allow(described_instance)
          .to receive(:execute).with command: kind_of(::Terraform::Command)
      end

      subject { apply_shell_out }

      it('is executed') { is_expected.to receive(:execute).with no_args }
    end
  end

  describe '#apply_constructively' do
    let(:plan_command_class) { ::Terraform::PlanCommand }

    after { described_instance.apply_constructively }

    it_behaves_like '#apply'
  end

  describe '#apply_destructively' do
    let(:plan_command_class) { ::Terraform::DestructivePlanCommand }

    after { described_instance.apply_destructively }

    it_behaves_like '#apply'
  end

  describe '#each_output_name' do
    include_context '#output_parser'

    let :output_value do
      ::JSON.dump 'output_name_1' => 'output_value_1',
                  'output_name_2' => 'output_value_2'
    end

    subject { ->(block) { described_instance.each_output_name(&block) } }

    it 'yields each output name' do
      is_expected.to yield_successive_args 'output_name_1', 'output_name_2'
    end
  end

  describe '#iterate_output' do
    include_context '#output_parser'

    let(:output_value) { ::JSON.dump 'value' => %w(value1 value2) }

    subject do
      ->(block) { described_instance.iterate_output name: 'name', &block }
    end

    it 'iterates the output values' do
      is_expected.to yield_successive_args 'value1', 'value2'
    end
  end

  describe '#load_state' do
    before do
      allow(described_instance).to receive(:execute)
        .with(command: kind_of(::Terraform::ShowCommand)).and_yield state
    end

    subject { ->(block) { described_instance.load_state(&block) } }

    context 'when state does exist' do
      let(:state) { 'state' }

      it('yields') { is_expected.to yield_control }
    end

    context 'when state does not exist' do
      let(:state) { '' }

      it('takes no action') { is_expected.to_not yield_control }
    end
  end

  describe '#output' do
    include_context '#output_parser'

    let(:output_value) { ::JSON.dump 'value' => 'value' }

    let(:version) { '0.6' }

    subject { described_instance.output name: 'name' }

    it('returns the output value') { is_expected.to eq 'value' }
  end

  describe '#version' do
    before do
      allow(described_instance).to receive(:execute)
        .with(command: kind_of(::Terraform::VersionCommand)).and_yield '0.1'
    end

    subject { described_instance.version }

    it 'returns the version' do
      is_expected.to be_instance_of ::Terraform::Version
    end
  end
end
