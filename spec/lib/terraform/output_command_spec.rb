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

require 'terraform/output_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::OutputCommand do
  let(:described_instance) { described_class.new state: state, name: target }

  let(:state) { '<state_pathname>' }

  let(:target) { '<name>' }

  it_behaves_like Terraform::Command do
    let(:command_options) { "-state=#{state}" }

    let(:name) { 'output' }
  end

  describe '#handle(error:)' do
    let(:error) { instance_double Exception }

    before do
      allow(error).to receive(:message).with(no_args).and_return message

      allow(error).to receive(:backtrace).with no_args
    end

    subject { proc { described_instance.handle error: error } }

    context 'when the error message does match the pattern' do
      let(:message) { 'nothing to output' }

      it 'does raise an error' do
        is_expected.to raise_error Terraform::OutputNotFound
      end
    end

    context 'when the error message does not match the pattern' do
      let(:message) { 'a thing to output' }

      it('does not raise an error') { is_expected.to_not raise_error }
    end
  end
end
