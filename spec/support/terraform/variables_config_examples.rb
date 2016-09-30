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

require 'terraform/variables_config'

RSpec.shared_examples Terraform::VariablesConfig do
  shared_context '#deprecated_variables_format(value:)' do
    let :log_deprecation do
      receive(:config_deprecated)
        .with attribute: 'variables', remediation: 'Use a mapping',
              type: 'a list or string', version: '1.0'
    end
  end

  describe '#coerce_variables(value:)' do
    let(:call_method) { described_instance.coerce_variables value: value }

    let(:variable_name) { 'foo' }

    let(:variable_value) { 'bar' }

    shared_examples 'the value can be coerced to be a mapping' do
      before { call_method }

      subject { described_instance[:variables] }

      it 'updates the config assignment' do
        is_expected.to eq variable_name => variable_value
      end
    end

    context 'when the value is in a deprecated format' do
      include_context '#deprecated_variables_format(value:)'

      let(:value) { "#{variable_name}=#{variable_value}" }

      before { allow(described_instance).to log_deprecation }

      it_behaves_like 'the value can be coerced to be a mapping'

      describe 'a deprecation' do
        after { call_method }

        subject { described_instance }

        it('is reported') { is_expected.to log_deprecation }
      end
    end

    context 'when the value is in a supported format' do
      let(:value) { { variable_name => variable_value } }

      it_behaves_like 'the value can be coerced to be a mapping'
    end

    context 'when the value can not be coerced to be a mapping' do
      let(:value) { 1 }

      after { call_method }

      subject { described_instance }

      it 'an error is reported' do
        is_expected.to receive(:config_error)
          .with attribute: 'variables',
                expected: 'a mapping of Terraform variable assignments'
      end
    end
  end

  describe '#finalize_config!(instance)' do
    include_context 'finalize_config! instance'

    describe '[:variables]' do
      subject { described_instance[:variables] }

      it('defaults to an empty mapping') { is_expected.to eq({}) }
    end
  end
end
