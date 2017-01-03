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

require 'kitchen/driver/terraform'
require 'support/terraform/client_context'
require 'support/terraform/configurable_context'
require 'support/terraform/configurable_examples'

::RSpec.describe ::Kitchen::Driver::Terraform do
  include_context 'instance'

  let(:described_instance) { driver }

  it_behaves_like ::Terraform::Configurable

  describe '.serial_actions' do
    subject(:serial_actions) { described_class.serial_actions }

    it('is empty') { is_expected.to be_empty }
  end

  describe '#destroy' do
    include_context 'client'

    before { allow(client).to receive(:state).with(no_args).and_return state }

    after { described_instance.destroy }

    subject { client }

    context 'when a state does exist' do
      let(:state) { 'foo' }

      it 'applies destructively' do
        is_expected.to receive(:apply_destructively).with no_args
      end
    end

    context 'when a state does not exist' do
      let(:state) { '' }

      it('takes no action') { is_expected.to_not receive :apply_destructively }
    end
  end

  describe '#verify_dependencies' do
    include_context 'client'

    before do
      allow(client_class).to receive(:new)
        .with(logger: kind_of(::Terraform::DebugLogger)).and_return client

      allow(client).to receive(:version).with(no_args)
        .and_return ::Terraform::Version.new value: version
    end

    context 'when the Terraform version is not supported' do
      let(:version) { '0.8' }

      subject { proc { described_instance.verify_dependencies } }

      it 'raises a user error' do
        is_expected.to raise_error(
          ::Kitchen::UserError,
          "Terraform v0.8 is not supported\nInstall Terraform v0.7"
        )
      end
    end

    context 'when the Terraform version is deprecated' do
      let(:version) { '0.6' }

      after { described_instance.verify_dependencies }

      subject { described_instance }

      it 'logs a deprecation' do
        is_expected.to receive(:log_deprecation)
          .with aspect: 'Terraform v0.6', remediation: 'Install Terraform v0.7'
      end
    end
  end
end
