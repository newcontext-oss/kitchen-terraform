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

require 'kitchen/driver/terraform'
require 'support/raise_error_examples'
require 'support/terraform/cli_config_examples'
require 'support/terraform/configurable_context'
require 'support/terraform/configurable_examples'

::RSpec.describe ::Kitchen::Driver::Terraform do
  include_context 'instance'

  let(:described_instance) { driver }

  it_behaves_like ::Terraform::CLIConfig

  it_behaves_like ::Terraform::Configurable

  describe '.serial_actions' do
    subject(:serial_actions) { described_class.serial_actions }

    it('is empty') { is_expected.to be_empty }
  end

  describe '#destroy' do
    include_context 'client'

    include_context 'silent_client'

    let :allow_load_state do
      allow(silent_client).to receive(:load_state).with(no_args)
    end

    context 'when a state does exist' do
      before { allow_load_state.and_yield }

      after { described_instance.destroy }

      subject { client }

      it 'applies destructively' do
        is_expected.to receive(:apply_destructively).with no_args
      end
    end

    context 'when a state does not exist' do
      before { allow_load_state.and_raise ::Errno::ENOENT, 'state file' }

      after { described_instance.destroy }

      subject { described_instance }

      it 'logs a debug message' do
        is_expected.to receive(:debug).with(/state file/)
      end
    end

    context 'when a command fails' do
      before { allow_load_state.and_raise ::SystemCallError, 'system call' }

      subject { proc { described_instance.destroy } }

      it 'raises an action failed error' do
        is_expected.to raise_error ::Kitchen::ActionFailed, /system call/
      end
    end
  end

  describe '#verify_dependencies' do
    include_context 'client'

    before do
      allow(::Terraform::Client).to receive(:new)
        .with(config: driver, logger: duck_type(:<<)).and_return client

      allow(client).to receive(:version).with(no_args)
        .and_return ::Terraform::Version.create value: version
    end

    context 'when the Terraform version is not supported' do
      let(:version) { '0.9' }

      it_behaves_like 'a user error has occurred' do
        let(:described_method) { described_instance.verify_dependencies }

        let :message do
          "Terraform v0.9 is not supported\nInstall Terraform v0.8"
        end
      end
    end

    context 'when the Terraform version is deprecated' do
      let(:version) { '0.6' }

      after { described_instance.verify_dependencies }

      subject { described_instance }

      it 'logs a deprecation' do
        is_expected.to receive(:log_deprecation)
          .with aspect: 'Terraform v0.6', remediation: 'Install Terraform v0.8'
      end
    end
  end
end
