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

require 'kitchen'
require 'kitchen/provisioner/terraform'
require 'kitchen/transport/ssh'
require 'terraform/configurable'
require_relative 'configurable_context'

RSpec.shared_examples Terraform::Configurable do
  include_context '#instance'

  let(:attribute) { :foo }

  let(:expected) { 'bar' }

  describe '@api_version' do
    subject :api_version do
      described_class.instance_variable_get :@api_version
    end

    it('equals 2') { is_expected.to eq 2 }
  end

  describe '@plugin_version' do
    subject :plugin_version do
      described_class.instance_variable_get :@plugin_version
    end

    it('equals the gem version') { is_expected.to be Terraform::VERSION }
  end

  describe '#config_deprecated(attribute:, expected:)' do
    include_context '#logger'

    let :receive_correction do
      receive(:warn).with "#{described_class}#{instance_name}" \
                            "#config[:#{attribute}] should be #{expected}"
    end

    let(:receive_notice) { receive(:warn).with 'DEPRECATION NOTICE' }

    before do
      allow(logger).to receive_notice

      allow(logger).to receive_correction
    end

    after do
      described_instance.config_deprecated attribute: attribute,
                                           expected: expected
    end

    subject { logger }

    it('reports a deprecation') { is_expected.to receive_notice }

    it('suggests a correction') { is_expected.to receive_correction }
  end

  describe '#config_error(attribute:, expected:)' do
    subject do
      proc do
        described_instance.config_error attribute: attribute, expected: expected
      end
    end

    it 'raises a user error regarding the config attribute' do
      is_expected.to raise_error Kitchen::UserError,
                                 "#{described_class}#{instance_name}" \
                                   "#config[:#{attribute}] must be " \
                                   "interpretable as #{expected}"
    end
  end

  describe '#instance_pathname(filename:)' do
    include_context '#instance'

    let(:filename) { 'foo' }

    subject { described_instance.instance_pathname filename: filename }

    it 'returns a pathname under the hidden instance directory' do
      is_expected
        .to eq "#{kitchen_root}/.kitchen/kitchen-terraform/instance/#{filename}"
    end
  end

  describe '#driver' do
    include_context '#driver'

    subject { described_instance.driver }

    it('returns the driver of the instance') { is_expected.to be driver }
  end

  describe '#provisioner' do
    include_context '#provisioner'

    subject { described_instance.provisioner }

    it 'returns the provisioner of the instance' do
      is_expected.to be provisioner
    end
  end

  describe '#transport' do
    include_context '#transport'

    subject { described_instance.transport }

    it('returns the transport of the instance') { is_expected.to be transport }
  end

  describe '#provisioner' do
    include_context '#provisioner'

    subject { described_instance.provisioner }

    it('returns the instance\'s provisioner') { is_expected.to be provisioner }
  end

  describe '#transport' do
    include_context '#transport'

    subject { described_instance.transport }

    it('returns the instance\'s transport') { is_expected.to be transport }
  end
end
