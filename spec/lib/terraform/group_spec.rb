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

require 'kitchen/verifier/terraform'
require 'terraform/group'

RSpec.describe Terraform::Group do
  let(:described_instance) do
    described_class.new data: data
  end

  describe '#each_attribute(&block)' do
    let(:data) { { attributes: { key_1 => value_1, key_2 => value_2 } } }

    let(:key_1) { instance_double Object }

    let(:value_1) { instance_double Object }

    let(:key_2) { instance_double Object }

    let(:value_2) { instance_double Object }

    subject { ->(block) { described_instance.each_attribute(&block) } }

    it 'enumerates each attribute pair' do
      is_expected.to yield_successive_args [key_1, value_1], [key_2, value_2]
    end
  end

  describe '#hostnames' do
    let(:data) { { hostnames: hostnames } }

    let(:hostnames) { instance_double Object }

    subject { described_instance.hostnames }

    it('returns the hostnames data') { is_expected.to eq hostnames }
  end

  describe '#store_attribute(key:, value:)' do
    let(:data) { { attributes: {} } }

    let(:key) { instance_double Object }

    let(:value) { instance_double Object }

    before { described_instance.store_attribute key: key, value: value }

    subject { data[:attributes][key] }

    it('stores the attribute pair data') { is_expected.to eq value }
  end
end
