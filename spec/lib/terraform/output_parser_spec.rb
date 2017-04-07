# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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
require 'terraform/version'

::RSpec.describe ::Terraform::OutputParser do
  let(:described_instance) { described_class.new output: output }

  describe '.create' do
    subject do
      described_class
        .create output: 'output',
                version: ::Terraform::Version.create(value: version)
    end

    context 'when the version does support JSON' do
      let(:version) { '0.8' }

      it 'returns an OutputParser' do
        is_expected.to be_instance_of described_class
      end
    end

    context 'when the version does not support JSON' do
      let(:version) { '0.6' }

      it 'returns a DeprecatedOutputParser' do
        is_expected.to be_instance_of ::Terraform::DeprecatedOutputParser
      end
    end
  end

  describe '#each_name' do
    let :output do
      ::JSON.dump 'output_name_1' => 'output_value_1',
                  'output_name_2' => 'output_value_2'
    end

    subject do lambda do |block| described_instance.each_name(&block) end end

    it 'yields each output name' do
      is_expected.to yield_successive_args 'output_name_1', 'output_name_2'
    end
  end

  describe '#iterate_parsed_output' do
    let(:output) { ::JSON.dump 'value' => ['foo', 'bar'] }

    subject do lambda do |block| described_instance.iterate_parsed_output(&block) end end

    it 'yields each element' do
      is_expected.to yield_successive_args 'foo', 'bar'
    end
  end

  describe '#parsed_output' do
    let(:output) { ::JSON.dump 'value' => 'foo' }

    subject { described_instance.parsed_output }

    it('returns the value\'s "value" field') { is_expected.to eq 'foo' }
  end
end
