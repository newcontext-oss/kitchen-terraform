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

require 'terraform/group'

RSpec.describe Terraform::Group do
  let :create_instance do
    proc { |block| described_class.new(**keyword_arguments, &block) }
  end

  let(:described_instance) { create_instance.call }

  let(:keyword_arguments) { required_arguments.merge optional_arguments }

  let(:optional_arguments) { {} }

  let :required_arguments do
    {
      hostnames: 'hostnames', name: 'name',
      transport: { port: 1, username: 'username' }
    }
  end

  describe '.new(attributes: {}, controls: [], hostnames:, name:, port: nil, ' \
             'transport:, username: nil)' do
    subject { create_instance }

    context 'when all arguments are valid' do
      it 'yields the new instance' do
        is_expected.to yield_with_args kind_of described_class
      end
    end

    context 'when an argument is invalid' do
      context 'attributes can not be interpretted as a hash' do
        let(:optional_arguments) { { attributes: [1, 2, 3] } }

        it 'raises a type error' do
          is_expected.to raise_error TypeError, /can't convert/
        end
      end

      context 'port can not be interpretted as an integer' do
        let(:optional_arguments) { { port: 'a' } }

        it 'raises an argument error' do
          is_expected.to raise_error ArgumentError, /invalid value.*"a"/
        end
      end

      context 'transport port can not be interpreted as an integer' do
        let(:optional_arguments) { { transport: { port: 'b' } } }

        it 'raises an argument error' do
          is_expected.to raise_error ArgumentError, /invalid value.*"b"/
        end
      end
    end
  end

  describe '#each_attribute_pair(&block)' do
    let(:attributes) { { foo: 'bar' } }

    let(:optional_arguments) { { attributes: attributes } }

    subject { ->(block) { described_instance.each_attribute_pair(&block) } }

    it 'yields each attribute pair' do
      is_expected.to yield_with_args(*Array(attributes))
    end
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it('returns the group name') { is_expected.to be described_instance.name }
  end
end
