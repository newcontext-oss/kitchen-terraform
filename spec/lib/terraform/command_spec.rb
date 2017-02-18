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

require 'support/terraform/command_context'
require 'terraform/command'

RSpec.describe Terraform::Command do
  let(:described_instance) { described_class.new target: target }

  let(:target) { instance_double Object }

  describe '#name' do
    subject { described_instance.name }

    it('returns an empty string') { is_expected.to eq '' }
  end

  describe '#options' do
    subject { described_instance.options }

    it('returns "--help"') { is_expected.to eq '--help' }
  end

  describe '#output' do
    include_context '#shell_out'

    let(:value) { instance_double Object }

    before { allow_stdout.and_return value }

    subject { described_instance.output }

    it('returns unprocessed output') { is_expected.to eq value }
  end

  describe '#run(logger:, timeout:)' do
    include_context '#shell_out'

    let(:check_error) { receive(:error!).with no_args }

    let(:logger) { instance_double Object }

    let(:run_command) { receive(:run_command).with no_args }

    let(:set_live_stream) { receive(:live_stream=).with logger }

    let(:set_timeout) { receive(:timeout=).with timeout }

    let(:timeout) { instance_double Object }

    before do
      allow(shell_out).to set_live_stream

      allow(shell_out).to set_timeout

      allow(shell_out).to run_command

      allow(shell_out).to check_error
    end

    describe 'executing the shell out command' do
      after { described_instance.run logger: logger, timeout: timeout }

      subject { shell_out }

      it 'uses the logger for live streaming' do
        is_expected.to set_live_stream
      end

      it('configures a timeout duration') { is_expected.to set_timeout }

      it('runs the command') { is_expected.to run_command }
    end

    describe 'checking for errors' do
      context 'when there is an error' do
        before { allow(shell_out).to check_error.and_raise }

        subject do
          proc { described_instance.run logger: logger, timeout: timeout }
        end

        it('raises the exception') { is_expected.to raise_error }
      end
    end
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it 'returns the command string' do
      is_expected.to eq "terraform  --help #{target}"
    end
  end
end
