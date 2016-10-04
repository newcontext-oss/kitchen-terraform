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
require 'terraform/command_executor'
require_relative 'configurable_context'

RSpec.shared_examples Terraform::CommandExecutor do
  describe '#execute(command:, timeout: ' \
             'Mixlib::ShellOut::DEFAULT_READ_TIMEOUT)' do
    include_context '#logger'

    let :allow_command_run do
      allow(command).to receive(:run).with logger: logger, timeout: timeout
    end

    let :call_method do
      proc { described_instance.execute command: command, timeout: timeout }
    end

    let(:command) { instance_double Terraform::Command }

    let(:timeout) { instance_double Object }

    before do
      allow(command).to receive(:to_s).with(no_args).and_return 'command'
    end

    context 'when the command does execute successfully' do
      let(:output) { instance_double Object }

      before do
        allow_command_run

        allow(command).to receive(:output).with(no_args).and_return output
      end

      subject do
        lambda do |block|
          described_instance.execute command: command, timeout: timeout, &block
        end
      end

      it('yields the output') { is_expected.to yield_with_args output }
    end

    context 'when the command does not execute successfully due to a ' \
              'permissions error' do
      before { allow_command_run.and_raise Errno::EACCES }

      subject { call_method }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure,
                                   '`command` failed: "Permission denied"'
      end
    end

    context 'when the command does not execute successfully due to no ' \
              'executable found' do
      before { allow_command_run.and_raise Errno::ENOENT }

      subject { call_method }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure,
                                   '`command` failed: "No such file or ' \
                                     'directory"'
      end
    end

    context 'when the command does not execute successfully due to a timeout' do
      before { allow_command_run.and_raise Mixlib::ShellOut::CommandTimeout }

      subject { call_method }

      it 'raises a transient failure' do
        is_expected.to raise_error Kitchen::TransientFailure,
                                   /`command` failed: ".*"/
      end
    end

    context 'when the command does not execute successfully due to a failure' do
      before do
        allow_command_run.and_raise Mixlib::ShellOut::ShellCommandFailed
      end

      subject { call_method }

      it 'raises a transient failure' do
        is_expected.to raise_error Kitchen::TransientFailure,
                                   /`command` failed: ".*"/
      end
    end
  end
end
