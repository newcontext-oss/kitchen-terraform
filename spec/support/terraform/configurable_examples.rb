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

require 'kitchen'
require 'support/raise_error_examples'
require 'support/terraform/configurable_context'
require 'terraform/configurable'

::RSpec.shared_examples ::Terraform::Configurable do
  let(:attr) { object }

  let :formatted_config do
    "#{described_class}#{instance.to_str}#config[:#{attr}]"
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

  describe '#client' do
    let(:client) { instance_double ::Object }

    before do
      allow(::Terraform::Client).to receive(:new)
        .with(config: duck_type(:[]), logger: instance_of(::Kitchen::Logger))
        .and_return client
    end

    subject { described_instance.client }

    it('returns a configured client') { is_expected.to be client }
  end

  describe '#config_deprecated' do
    let(:remediation) { instance_double ::Object }

    let(:type) { instance_double ::Object }

    after do
      described_instance.config_deprecated attr: attr, remediation: remediation,
                                           type: type
    end

    subject { described_instance }

    it 'logs the deprecation' do
      is_expected.to receive(:log_deprecation)
        .with aspect: "#{formatted_config} as #{type}", remediation: remediation
    end
  end

  describe '#config_error' do
    it_behaves_like 'a user error has occurred' do
      let :described_method do
        described_instance.config_error attr: attr, expected: 'expected'
      end

      let(:message) { "#{formatted_config} must be interpretable as expected" }
    end
  end

  describe '#debug_logger' do
    subject { described_instance.debug_logger }

    it 'is a debug logger' do
      is_expected.to be_instance_of ::Terraform::DebugLogger
    end
  end

  describe '#driver' do
    subject { described_instance.driver }

    it 'returns the driver of the instance' do
      is_expected.to be instance.driver
    end
  end

  describe '#instance_pathname' do
    let(:filename) { 'filename' }

    subject { described_instance.instance_pathname(filename: filename).to_path }

    it 'returns a pathname under the hidden instance directory' do
      is_expected.to eq '/kitchen/root/.kitchen/kitchen-terraform/' \
                          'suite-platform/filename'
    end
  end

  describe '#log_deprecation' do
    let(:aspect) { object }

    let(:remediation) { object }

    let(:warn_deprecation) { receive(:warn).with 'DEPRECATION NOTICE' }

    let :warn_deprecated_feature do
      receive(:warn)
        .with "Support for #{aspect} will be dropped in kitchen-terraform v1.0"
    end

    let(:warn_remediation) { receive(:warn).with remediation }

    before do
      allow(logger).to warn_deprecation

      allow(logger).to warn_deprecated_feature

      allow(logger).to warn_remediation
    end

    after do
      described_instance.log_deprecation aspect: aspect,
                                         remediation: remediation
    end

    subject { logger }

    it('warns of the deprecation') { is_expected.to warn_deprecation }

    it 'warns of the deprecated feature' do
      is_expected.to warn_deprecated_feature
    end

    it('warns of the remediation') { is_expected.to warn_remediation }
  end

  describe '#provisioner' do
    subject { described_instance.provisioner }

    it 'returns the provisioner of the instance' do
      is_expected.to be instance.provisioner
    end
  end

  describe '#silent_client' do
    let(:silent_client) { object }

    before do
      allow(::Terraform::Client).to receive(:new).with(
        config: kind_of(::Kitchen::Configurable),
        logger: instance_of(::Terraform::DebugLogger)
      ).and_return silent_client
    end

    subject { described_instance.silent_client }

    it 'returns a client with color disabled and debug output' do
      is_expected.to be silent_client
    end
  end

  describe '#transport' do
    subject { described_instance.transport }

    it 'returns the transport of the instance' do
      is_expected.to be instance.transport
    end
  end
end
