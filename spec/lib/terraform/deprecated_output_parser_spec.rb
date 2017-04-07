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

require 'terraform/deprecated_output_parser'

::RSpec.describe ::Terraform::DeprecatedOutputParser do
  let(:described_instance) { described_class.new output: output }

  describe '#each_name' do
    let :output do
      "output_name_1 = output_value_1\noutput_name_2 = output_value_2"
    end

    subject do lambda do |block| described_instance.each_name(&block) end end

    it 'yields each output name' do
      is_expected.to yield_successive_args 'output_name_1', 'output_name_2'
    end
  end

  describe '#iterate_parsed_output' do
    subject do lambda do |block| described_instance.iterate_parsed_output(&block) end end

    let(:output) { 'foo,bar' }

    it 'yields each field' do
      is_expected.to yield_successive_args 'foo', 'bar'
    end
  end

  describe '#parsed_output' do
    let(:output) { "bar\n" }

    subject { described_instance.parsed_output }

    it('returns the stripped output') { is_expected.to eq 'bar' }
  end
end
