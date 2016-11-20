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
  shared_context '#formatted(attribute:)' do
    include_context '#instance'

    let :formatted_attribute do
      "#{described_class}#{instance_name}#config[:#{attribute}]"
    end
  end

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

    it 'equals the gem version' do
      is_expected.to be ::Terraform::PROJECT_VERSION
    end
  end

  describe '#config_deprecated(attribute:, remediation:, type:, version:)' do
    include_context '#formatted(attribute:)'

    let(:attribute) { instance_double Object }

    let(:remediation) { instance_double Object }

    let(:type) { instance_double Object }

    let(:version) { instance_double Object }

    after do
      described_instance.config_deprecated attribute: attribute,
                                           remediation: remediation, type: type,
                                           version: version
    end

    subject { described_instance }

    it 'logs the deprecation' do
      is_expected.to receive(:log_deprecation)
        .with aspect: "#{formatted_attribute} as #{type}",
              remediation: remediation, version: version
    end
  end

  describe '#config_error(attribute:, expected:)' do
    include_context '#formatted(attribute:)'

    let(:attribute) { instance_double Object }

    let(:expected) { instance_double Object }

    subject do
      proc do
        described_instance.config_error attribute: attribute, expected: expected
      end
    end

    it 'raises a user error regarding the config attribute' do
      is_expected.to raise_error Kitchen::UserError,
                                 "#{formatted_attribute} must be " \
                                   "interpretable as #{expected}"
    end
  end

  describe '#driver' do
    include_context '#driver'

    subject { described_instance.driver }

    it('returns the driver of the instance') { is_expected.to be driver }
  end

  describe '#instance_pathname(filename:)' do
    include_context '#instance'

    let(:filename) { 'foo' }

    subject { described_instance.instance_pathname filename: filename }

    it 'returns a pathname under the hidden instance directory' do
      is_expected.to eq "#{kitchen_root}/.kitchen/kitchen-terraform/" \
                          "#{instance_name}/#{filename}"
    end
  end

  describe '#log_deprecation(aspect:, remediation:, version:)' do
    include_context '#logger'

    let(:aspect) { instance_double Object }

    let(:remediation) { instance_double Object }

    let(:version) { instance_double Object }

    let(:warn_deprecation) { receive(:warn).with 'DEPRECATION NOTICE' }

    let :warn_deprecated_feature do
      receive(:warn).with "Support for #{aspect} will be dropped in " \
                            "kitchen-terraform v#{version}"
    end

    let(:warn_remediation) { receive(:warn).with remediation }

    before do
      allow(logger).to warn_deprecation

      allow(logger).to warn_deprecated_feature

      allow(logger).to warn_remediation
    end

    after do
      described_instance.log_deprecation aspect: aspect,
                                         remediation: remediation,
                                         version: version
    end

    subject { logger }

    it('warns of the deprecation') { is_expected.to warn_deprecation }

    it 'warns of the deprecated feature' do
      is_expected.to warn_deprecated_feature
    end

    it('warns of the remediation') { is_expected.to warn_remediation }
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
end
