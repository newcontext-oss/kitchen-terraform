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

require 'kitchen/provisioner/terraform'
require 'kitchen/verifier/terraform'
require 'support/terraform/configurable_examples'
require 'terraform/group'
require 'terraform/inspec_runner'

RSpec.describe Terraform::Group do
  let :described_instance do
    described_class.new value: value, verifier: verifier
  end

  let(:port) { 1 }

  let(:provisioner) { instance_double Kitchen::Provisioner::Terraform }

  let(:transport) { instance_double Kitchen::Transport::Ssh }

  let(:username) { instance_double Object }

  let(:value) { { attributes: {} } }

  let(:verifier) { Kitchen::Verifier::Terraform.new }

  before do
    allow(verifier).to receive(:transport).with(no_args).and_return transport

    allow(verifier).to receive(:provisioner).with(no_args)
      .and_return provisioner

    allow(transport).to receive(:[]).with(:port).and_return port

    allow(transport).to receive(:[]).with(:username).and_return username
  end

  describe '.new(value:, verifier:)' do
    let(:instance) { instance_double Kitchen::Instance }

    before do
      allow(verifier).to receive(:instance).with(no_args).and_return instance

      allow(instance).to receive(:to_str).with(no_args).and_return 'instance'
    end

    context 'when a port is not specified' do
      subject { described_instance[:port] }

      it('defaults to the transport port') { is_expected.to eq port }
    end

    context 'when a username is not specified' do
      subject { described_instance[:user] }

      it 'defaults to the transport username' do
        is_expected.to eq username.to_s
      end
    end

    context 'when the value can not be coerced to be a mapping' do
      let(:value) { 'a' }

      after { described_instance }

      subject { verifier }

      it 'an error is reported' do
        is_expected.to receive(:config_error)
          .with attribute: /groups\]\[.*/, expected: 'a group mapping'
      end
    end

    context 'when the attributes can not be coerced to be a mapping' do
      before { value[:attributes] = 'a' }

      after { described_instance }

      subject { verifier }

      it 'an error is reported' do
        is_expected.to receive(:config_error)
          .with attribute: /groups\]\[{.*}\]\[:attributes/,
                expected: 'a mapping of Inspec attribute names to Terraform ' \
                            'output variable names'
      end
    end

    context 'when the port can not be coerced to be an integer' do
      before { value[:port] = 'a' }

      after { described_instance }

      subject { verifier }

      it 'an error is reported' do
        is_expected.to receive(:config_error)
          .with attribute: /groups\]\[.*\]\[:port/, expected: 'an integer'
      end
    end
  end

  describe '#populate(runner:)' do
    let(:output_name) { instance_double Object }

    let(:output_value) { instance_double Object }

    let(:runner) { instance_double Terraform::InspecRunner }

    before do
      value[:attributes] = { key: output_name }

      allow(provisioner).to receive(:output).with(name: output_name)
        .and_return output_value
    end

    after { described_instance.populate runner: runner }

    subject { runner }

    it 'sets runner attributes using Terraform output values' do
      is_expected.to receive(:set_attribute).with key: :key, value: output_value
    end
  end

  describe '#verify_each_host(options:)' do
    let(:hostname) { instance_double Object }

    let(:hostnames) { instance_double Object }

    let(:options) { {} }

    before do
      value[:hostnames] = hostnames

      allow(provisioner).to receive(:each_list_output)
        .with(name: hostnames.to_s).and_yield hostname

      allow(described_instance).to receive(:store).with :host, hostname

      allow(verifier).to receive(:info).with kind_of String
    end

    after { described_instance.verify_each_host options: options }

    subject do
      class_double(Terraform::InspecRunner).as_stubbed_const
    end

    it 'verifies each host in the group' do
      is_expected.to receive(:run_and_verify)
        .with group: described_instance, options: described_instance,
              verifier: verifier
    end
  end
end
