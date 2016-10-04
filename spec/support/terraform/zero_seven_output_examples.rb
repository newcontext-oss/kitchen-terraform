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

require 'terraform/zero_seven_output'
require_relative 'command_context'

RSpec.shared_examples Terraform::ZeroSevenOutput do
  describe '#options' do
    subject { described_instance.options }

    it 'returns "-json=true -state=<state_pathname>"' do
      is_expected.to eq "-json=true -state=#{state}"
    end
  end

  describe '#output' do
    include_context '#shell_out'

    let(:stdout) { "{'value': '#{value}'}" }

    let(:value_1) { 'foo' }

    let(:value_2) { 'bar' }

    subject { described_instance.output }

    context 'when the output value is indicated as a list' do
      let(:list) { true }

      before do
        allow_stdout.and_return %({"value": ["#{value_1}", "#{value_2}"]})
      end

      it('returns a list of values') { is_expected.to eq [value_1, value_2] }
    end

    context 'when the output value is not indicated as a list' do
      let(:list) { false }

      before { allow_stdout.and_return %({"value": "#{value_1}"}) }

      it('returns the value') { is_expected.to eq value_1 }
    end
  end
end
