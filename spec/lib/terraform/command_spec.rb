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

require 'terraform/command'

RSpec.describe Terraform::Command do
  let(:described_instance) { described_class.new logger: logger }

  let(:logger) { instance_double Object }

  describe '.execute(**keyword_arguments, &block)' do
    let(:instance) { instance_double described_class }

    before do
      allow(described_class).to receive(:new).with(logger: logger)
        .and_return instance
    end

    after { described_class.execute logger: logger }

    subject { instance }

    it 'creates and executes a command instance' do
      is_expected.to receive(:execute).with no_args
    end
  end

  describe '#execute' do
    let(:allow_error) { allow(shell_out).to receive(:error!).with no_args }

    let(:shell_out) { instance_double Mixlib::ShellOut }

    before do
      allow(described_instance).to receive(:shell_out).with(no_args)
        .and_return shell_out

      allow(shell_out).to receive(:run_command).with no_args

      allow(shell_out).to receive(:command).with(no_args).and_return 'command'
    end

    context 'when the execution is successful' do
      let(:stdout) { instance_double Object }

      before do
        allow_error

        allow(shell_out).to receive(:stdout).with(no_args).and_return stdout
      end

      subject { ->(block) { described_instance.execute(&block) } }

      it('yields the output') { is_expected.to yield_with_args stdout }
    end

    context 'when the execution is not successful due to a permissions error' do
      before { allow_error.and_raise Errno::EACCES }

      subject { proc { described_instance.execute } }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure
      end
    end

    context 'when the execution is not successful due to no executable found' do
      before { allow_error.and_raise Errno::ENOENT }

      subject { proc { described_instance.execute } }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure
      end
    end

    context 'when the execution is not successful due to a command timeout' do
      before { allow_error.and_raise Mixlib::ShellOut::CommandTimeout }

      subject { proc { described_instance.execute } }

      it 'raises a transient failure' do
        is_expected.to raise_error Kitchen::TransientFailure
      end
    end

    context 'when the execution is not successful due to a command failure' do
      before { allow_error.and_raise Mixlib::ShellOut::ShellCommandFailed }

      subject { proc { described_instance.execute } }

      it 'raises a transient failure' do
        is_expected.to raise_error Kitchen::TransientFailure
      end
    end
  end

  describe '#name' do
    subject { described_instance.name }

    it('returns an empty string') { is_expected.to eq '' }
  end

  describe '#options' do
    subject { described_instance.options }

    it('returns "--help"') { is_expected.to eq '--help' }
  end
end
