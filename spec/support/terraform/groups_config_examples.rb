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

require 'terraform/groups_config'
require 'support/terraform/configurable_context'

RSpec.shared_examples Terraform::GroupsConfig do
  describe '#coerce_attributes(group:)' do
    let(:call_method) { described_instance.coerce_attributes group: group }

    context 'when the attributes can be coerced to be a mapping' do
      let(:group) { { attributes: { foo: 'bar' } } }

      before { call_method }

      subject { group[:attributes] }

      it('updates the config assignment') { is_expected.to eq foo: 'bar' }
    end

    context 'when the attributes can not be coerced to be a mapping' do
      let(:group) { { attributes: 'foo' } }

      after { call_method }

      subject { described_instance }

      it 'reports an error' do
        is_expected.to receive(:config_error)
          .with attribute: "groups][#{group}][:attributes",
                expected: 'a mapping of Inspec attribute names to Terraform ' \
                            'output variable names'
      end
    end
  end

  describe '#coerce_controls(group:)' do
    let(:group) { { controls: 'foo' } }

    before { described_instance.coerce_controls group: group }

    subject { group[:controls] }

    it('coerces the value to be an array') { is_expected.to eq ['foo'] }
  end

  describe '#coerce_groups(value:)' do
    let(:group) { instance_double Terraform::Group }

    let(:group_class) { class_double(Terraform::Group).as_stubbed_const }

    let(:group_data) { instance_double Object }

    let(:value) { instance_double Object }

    before do
      allow(described_instance).to receive(:coerced_group).with(value: value)
        .and_return group_data

      allow(group_class).to receive(:new).with(data: group_data)
        .and_return group

      described_instance.coerce_groups value: value
    end

    subject { described_instance[:groups] }

    it('coerces the value to be an array') { is_expected.to eq [group] }
  end

  describe '#coerce_hostnames(group:)' do
    let(:group) { { hostnames: 1 } }

    before { described_instance.coerce_hostnames group: group }

    subject { group[:hostnames] }

    it('coerces the value to be a string') { is_expected.to eq '1' }
  end

  describe '#coerce_name(group:)' do
    let(:group) { { name: 1 } }

    before { described_instance.coerce_name group: group }

    subject { group[:name] }

    it('coerces the value to be a string') { is_expected.to eq '1' }
  end

  describe 'coerce_port(group:)' do
    include_context '#transport'

    let(:call_method) { described_instance.coerce_port group: group }

    context 'when the value can be coerced to be an integer' do
      let(:group) { { port: '1' } }

      before { call_method }

      subject { group[:port] }

      it('updates the config assignment') { is_expected.to eq 1 }
    end

    context 'when the value can not be coerced to be an integer' do
      let(:group) { { port: 'a' } }

      after { call_method }

      subject { described_instance }

      it 'reports an error' do
        is_expected.to receive(:config_error)
          .with attribute: "groups][#{group}][:port", expected: 'an integer'
      end
    end
  end

  describe '#coerce_username(group:)' do
    include_context '#transport'

    let(:group) { { username: 1 } }

    before { described_instance.coerce_username group: group }

    subject { group[:username] }

    it('coerces the value to be a string') { is_expected.to eq '1' }
  end

  describe '#coerced_group(value:)' do
    let(:call_method) { described_instance.coerced_group value: value }

    context 'when the value can be coerced to be a mapping' do
      include_context '#transport'

      let(:transport_port) { 1 }

      let(:transport_username) { 'foo' }

      let(:value) { {} }

      before do
        allow(transport).to receive(:[]).with(:port).and_return transport_port

        allow(transport).to receive(:[]).with(:username)
          .and_return transport_username
      end

      subject { call_method }

      it 'returns a coerced mapping' do
        is_expected.to eq attributes: {}, controls: [], hostnames: '', name: '',
                          port: transport_port, username: transport_username
      end
    end

    context 'when the value can not be coerced to be a mapping' do
      let(:value) { 'a' }

      after { call_method }

      subject { described_instance }

      it 'reports an error' do
        is_expected.to receive(:config_error)
          .with attribute: "groups][#{value}", expected: 'a group mapping'
      end
    end
  end

  describe '#finalize_config!(instance)' do
    include_context 'finalize_config! instance'

    describe '[:groups]' do
      subject { described_instance[:groups] }

      it('defaults to an empty collection') { is_expected.to eq [] }
    end
  end
end
