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

  describe '#run(logger:, timeout:)' do
    let(:check_error) { receive(:error!).with no_args }

    let(:logger) { instance_double Object }

    let(:run_command) { receive(:run_command).with no_args }

    let(:set_live_stream) { receive(:live_stream=).with logger }

    let(:set_timeout) { receive(:timeout=).with timeout }

    let(:shell_out) { instance_double Mixlib::ShellOut }

    let(:stdout) { instance_double Object }

    let(:timeout) { instance_double Object }

    before do
      allow(described_instance).to receive(:shell_out).with(no_args)
        .and_return shell_out

      allow(shell_out).to set_live_stream

      allow(shell_out).to set_timeout

      allow(shell_out).to run_command

      allow(shell_out).to check_error

      allow(shell_out).to receive(:stdout).with(no_args).and_return stdout
    end

    describe 'executing' do
      after { described_instance.run logger: logger, timeout: timeout }

      subject { shell_out }

      it 'uses the logger for live streaming' do
        is_expected.to set_live_stream
      end

      it('configures a timeout duration') { is_expected.to set_timeout }

      it('runs the command') { is_expected.to run_command }

      it('checks for errors') { is_expected.to check_error }
    end

    describe 'handling output' do
      subject do
        lambda do |block|
          described_instance.run logger: logger, timeout: timeout, &block
        end
      end

      it('yields the standard output') { is_expected.to yield_with_args stdout }
    end
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it 'returns the command string' do
      is_expected.to eq "terraform  --help #{target}"
    end
  end
end
