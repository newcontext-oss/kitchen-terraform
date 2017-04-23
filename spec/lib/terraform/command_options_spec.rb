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

require 'terraform/command_options'

::RSpec.describe ::Terraform::CommandOptions do
  let(:described_instance) { described_class.new options: options }

  let(:options) { ::Set.new }

  let(:value) { 'value' }

  shared_examples '#fetch' do |key|
    before { options.add ::Terraform::CommandOption.new key: key, value: value }

    subject { described_instance.send key.tr '-', '_' }

    it("fetches -#{key}") { is_expected.to eq value }
  end

  shared_examples '#store' do |key|
    before { described_instance.send "#{key.tr '-', '_'}=", value }

    subject { described_instance.to_s }

    it("sets -#{key}") { is_expected.to include "-#{key}=#{value}" }
  end

  describe '#color=' do
    before { described_instance.color = value }

    subject { described_instance.to_s }

    context 'when the value is true' do
      let(:value) { true }

      it('takes no action') { is_expected.to be_empty }
    end

    context 'when the value is false' do
      let(:value) { false }

      it 'sets -no-color' do
        is_expected.to include '-no-color'
      end
    end
  end

  describe '#destroy=' do
    it_behaves_like '#store', 'destroy'
  end

  describe '#input=' do
    it_behaves_like '#store', 'input'
  end

  describe '#json=' do
    it_behaves_like '#store', 'json'
  end

  describe '#out' do
    it_behaves_like '#fetch', 'out'
  end

  describe '#out=' do
    it_behaves_like '#store', 'out'
  end

  describe '#state' do
    it_behaves_like '#fetch', 'state'
  end

  describe '#state=' do
    it_behaves_like '#store', 'state'
  end

  describe '#state_out' do
    it_behaves_like '#fetch', 'state-out'
  end

  describe '#state_out=' do
    it_behaves_like '#store', 'state-out'
  end
end
