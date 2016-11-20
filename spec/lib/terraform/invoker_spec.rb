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

require 'terraform/invoker'

::RSpec.describe ::Terraform::Invoker do
  let(:described_instance) { described_class.new logger: ::Kitchen::Logger.new }

  describe '#execute' do
    let(:command) { instance_double ::Terraform::Command }

    let(:shell_out) { instance_double ::Terraform::ShellOut }

    before do
      allow(::Terraform::ShellOut).to receive(:new).with(
        command: command, logger: instance_of(::Kitchen::Logger),
        timeout: kind_of(::Integer)
      ).and_return shell_out
    end

    after { described_instance.execute command: command }

    subject { shell_out }

    context 'when the command\'s requirements are met' do
      before do
        allow(command).to receive(:if_requirements_not_met).with no_args

        allow(command).to receive(:prepare).with no_args
      end

      it 'executes the command' do
        is_expected.to receive(:execute).with no_args
      end
    end

    context 'when the command\'s requirements are not met' do
      before do
        allow(command).to receive(:if_requirements_not_met).with(no_args)
          .and_yield 'reason'
      end

      it('does not execute the command') { is_expected.to_not receive :execute }
    end
  end
end
