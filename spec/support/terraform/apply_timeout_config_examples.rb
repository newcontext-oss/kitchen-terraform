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

require 'terraform/apply_timeout_config'
require_relative 'configurable_context'

RSpec.shared_examples Terraform::ApplyTimeoutConfig do
  describe '#coerce_apply_timeout(value:)' do
    let(:call_method) { described_instance.coerce_apply_timeout value: value }

    context 'when the value can be coerced to be an integer' do
      let(:value) { 1 }

      before { call_method }

      subject { described_instance[:apply_timeout] }

      it('updates the config assignment') { is_expected.to eq value }
    end

    context 'when the value can not be coerced to be an integer' do
      let(:value) { 'a' }

      after { call_method }

      subject { described_instance }

      it 'an error is reported' do
        is_expected.to receive(:config_error).with attribute: 'apply_timeout',
                                                   expected: 'an integer'
      end
    end
  end

  describe '#finalize_config!(instance)' do
    include_context 'finalize_config! instance'

    describe '[:apply_timeout]' do
      subject { described_instance[:apply_timeout] }

      it('defaults to 600 seconds') { is_expected.to eq 600 }
    end
  end
end
