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

RSpec.shared_context '#finalize_config!(instance)' do
  include_context '#instance'

  include_context 'config'

  after { described_instance.finalize_config! instance }
end

RSpec.shared_context '#instance' do
  let(:instance) { instance_double Kitchen::Instance }

  let(:instance_name) { 'instance' }

  before do
    allow(described_instance).to receive(:instance).with(no_args)
      .and_return instance

    allow(instance).to receive(:name).with(no_args).and_return instance_name

    allow(instance).to receive(:to_str).with(no_args).and_return instance_name
  end
end

RSpec.shared_context '#logger' do
  let(:logger) { instance_double Kitchen::Logger }

  before do
    allow(described_instance).to receive(:logger).with(no_args)
      .and_return logger
  end
end

RSpec.shared_context '#provisioner' do
  include_context '#instance'

  let(:provisioner) { instance_double Kitchen::Provisioner::Terraform }

  before do
    allow(instance).to receive(:provisioner).with(no_args)
      .and_return provisioner
  end
end

RSpec.shared_context '#transport' do
  include_context '#instance'

  let(:transport) { instance_double Kitchen::Transport::Ssh }

  before do
    allow(instance).to receive(:transport).with(no_args)
      .and_return transport
  end
end

RSpec.shared_context 'config' do
  let(:config) { { kitchen_root: kitchen_root } }

  let(:kitchen_root) { Dir.pwd }
end

RSpec.shared_examples Terraform::Configurable do
  include_context '#instance'

  let(:attribute) { :foo }

  let(:expected) { 'bar' }

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
