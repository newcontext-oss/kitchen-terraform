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
             'Mixlib::ShellOut::DEFAULT_READ_TIMEOUT, &block)' do
    include_context '#logger'

    let :allow_command_run do
      allow(command).to receive(:run).with logger: logger, timeout: timeout
    end

    let(:command) { instance_double Terraform::Command }

    let(:timeout) { instance_double Object }

    before do
      allow(command).to receive(:to_s).with(no_args).and_return 'command'
    end

    subject do
      proc { described_instance.execute command: command, timeout: timeout }
    end

    context 'when the command does execute successfully' do
      before { allow_command_run }

      it('an error is not raised') { is_expected.to_not raise_error }
    end

    context 'when the command does not execute successfully due to a ' \
              'permissions error' do
      before { allow_command_run.and_raise Errno::EACCES }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure,
                                   '`command` failed: "Permission denied"'
      end
    end

    context 'when the command does not execute successfully due to no ' \
              'executable found' do
      before { allow_command_run.and_raise Errno::ENOENT }

      it 'raises an instance failure' do
        is_expected.to raise_error Kitchen::InstanceFailure,
                                   '`command` failed: "No such file or ' \
                                     'directory"'
      end
    end

    context 'when the command does not execute successfully due to a timeout' do
      before { allow_command_run.and_raise Mixlib::ShellOut::CommandTimeout }

      it 'raises a transient failure' do
        is_expected.to raise_error Kitchen::TransientFailure,
                                   /`command` failed: ".*"/
      end
    end

    context 'when the command does not execute successfully due to a failure' do
      before do
        allow_command_run.and_raise Mixlib::ShellOut::ShellCommandFailed
      end

      it 'raises a transient failure' do
        is_expected.to raise_error Kitchen::TransientFailure,
                                   /`command` failed: ".*"/
      end
    end
  end
end
