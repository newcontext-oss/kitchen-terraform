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

  describe '#evaluate(state:, verifier:)' do
    let(:attributes) { instance_double Object }

    let(:controls) { instance_double Object }

    let :data do
      {
        attributes: attributes, controls: controls, hostnames: hostnames,
        name: name, port: port, username: username
      }
    end

    let(:execute) { receive(:execute).with no_args }

    let(:hostname) { instance_double Object }

    let(:hostnames) { instance_double Object }

    let :log_execution do
      receive(:info).with "Verifying host '#{hostname}' of group '#{name}'"
    end

    let(:merge_host_option) { receive(:merge).with options: { host: hostname } }

    let :merge_static_options do
      receive(:merge).with options: {
        attributes: attributes, controls: controls, port: port, user: username
      }
    end

    let(:name) { instance_double Object }

    let(:port) { instance_double Object }

    let :resolve_attributes do
      receive(:resolve_attributes).with group: described_instance
    end

    let(:username) { instance_double Object }

    let(:verifier) { instance_double Kitchen::Verifier::Terraform }

    before do
      allow(verifier).to resolve_attributes

      allow(verifier).to receive(:resolve_hostnames)
        .with(group: described_instance).and_yield hostname

      allow(verifier).to log_execution

      allow(verifier).to merge_static_options

      allow(verifier).to merge_host_option

      allow(verifier).to execute
    end

    after { described_instance.evaluate verifier: verifier }

    subject { verifier }

    it('resolves the attributes') { is_expected.to resolve_attributes }

    it 'updates the static verifier options' do
      is_expected.to merge_static_options
    end

    it('logs the current host execution') { is_expected.to log_execution }

    it('updates the host verifier option') { is_expected.to merge_host_option }

    it('executes the verifier') { is_expected.to execute }
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
