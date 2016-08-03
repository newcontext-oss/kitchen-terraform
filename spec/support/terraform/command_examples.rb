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

RSpec.shared_examples Terraform::Command do
  let(:logger) { instance_double Object }

  describe '#execute' do
    let(:shell_out) { instance_double Mixlib::ShellOut }

    let :shell_out_class do
      class_double(Mixlib::ShellOut)
        .as_stubbed_const transfer_nested_constants: true
    end

    before do
      allow(shell_out_class)
        .to receive(:new).with(
          described_instance.to_s,
          returns: 0, timeout: Mixlib::ShellOut::DEFAULT_READ_TIMEOUT,
          live_stream: logger
        ).and_return shell_out

      allow(shell_out).to receive(:run_command).with no_args
    end

    context 'when the execution is successful' do
      let(:stdout) { instance_double Object }

      before do
        allow(shell_out).to receive(:error!).with no_args

        allow(shell_out).to receive(:stdout).with(no_args).and_return stdout
      end

      subject { ->(block) { described_instance.execute(&block) } }

      it('yields the output') { is_expected.to yield_with_args stdout }
    end

    context 'when the execution is not successful due to a standard error' do
      before { allow(shell_out).to receive(:error!).with(no_args).and_raise }

      subject { proc { described_instance.execute } }

      it('raises an error') { is_expected.to raise_error Terraform::Error }
    end
  end

  describe '#name' do
    let :supported_command_names do
      %w(apply destroy get output plan validate version)
    end

    subject { described_instance.name }

    it 'is a supported command' do
      is_expected.to(
        satisfy { |command_name| supported_command_names.include? command_name }
      )
    end
  end

  describe '#options' do
    subject { described_instance.options }

    it('is a hash') { is_expected.to be_kind_of Hash }
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it 'is the converted command string' do
      is_expected.to eq "terraform #{name} #{command_options} #{target}"
    end
  end
end
