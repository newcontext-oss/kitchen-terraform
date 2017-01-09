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
require 'terraform/shell_out'

::RSpec.describe ::Terraform::ShellOut do
  let(:command) { ::Terraform::Command.new }

  let :described_instance do
    described_class.new command: command, logger: ::Kitchen::Logger.new,
                        timeout: 1234
  end

  describe '#execute' do
    let(:shell_out) { instance_double ::Mixlib::ShellOut }

    before do
      allow(::Mixlib::ShellOut).to receive(:new).with(
        'terraform help', live_stream: instance_of(::Kitchen::Logger),
                          timeout: kind_of(::Integer)
      ).and_return shell_out

      allow(shell_out).to receive(:run_command).with no_args
    end

    subject { proc { |block| described_instance.execute(&block) } }

    context 'when the command does execute successfully' do
      before do
        allow(shell_out).to receive(:error!).with no_args

        allow(shell_out).to receive(:stdout).with(no_args).and_return 'stdout'
      end

      it 'yields the standard output' do
        is_expected.to yield_with_args 'stdout'
      end
    end

    context 'when the command does not execute successfully' do
      before do
        allow(shell_out).to receive(:error!).with(no_args)
          .and_raise ::Mixlib::ShellOut::ShellCommandFailed, 'error'

        allow(shell_out).to receive(:command).with(no_args).and_return command
      end

      it 'raises an instance failure' do
        is_expected.to raise_error ::Kitchen::StandardError,
                                   '`terraform help` failed: "error"'
      end
    end
  end
end
