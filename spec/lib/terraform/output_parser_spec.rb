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

require 'terraform/output_parser'

::RSpec.describe ::Terraform::OutputParser do
  let(:described_instance) { described_class.new value: value }

  describe '#iterate_parsed_output' do
    subject { ->(block) { described_instance.iterate_parsed_output(&block) } }

    context 'when the value is a CSV string' do
      let(:value) { 'foo,bar' }

      it 'yields each field' do
        is_expected.to yield_successive_args 'foo', 'bar'
      end
    end

    context 'when the value is a list' do
      let(:value) { ::JSON.dump 'value' => %w(foo bar) }

      it 'yields each element' do
        is_expected.to yield_successive_args 'foo', 'bar'
      end
    end
  end

  describe '#parsed_output' do
    subject { described_instance.parsed_output }

    context 'when the value is a JSON string' do
      let(:value) { ::JSON.dump 'value' => 'foo' }

      it('returns the value\'s "value" field') { is_expected.to eq 'foo' }
    end

    context 'when the value is not a JSON string' do
      let(:value) { 'bar' }

      it('returns the value') { is_expected.to eq 'bar' }
    end
  end
end
