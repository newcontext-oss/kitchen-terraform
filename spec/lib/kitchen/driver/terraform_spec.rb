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
require 'support/terraform/client_examples'
require 'support/terraform/configurable_context'
require 'support/terraform/configurable_examples'

RSpec.describe Kitchen::Driver::Terraform do
  include_context 'config'

  let(:described_instance) { described_class.new config }

  it_behaves_like Terraform::Client

  it_behaves_like Terraform::Configurable

  describe '.serial_actions' do
    subject(:serial_actions) { described_class.serial_actions }

    it('is empty') { is_expected.to be_empty }
  end

  describe '#create(_state = nil)' do
    include_context '#provisioner'

    let :create_plan_directory do
      receive(:mkdir_p).with plan_directory_pathname
    end

    let :create_state_directory do
      receive(:mkdir_p).with state_directory_pathname
    end

    let(:file_class) { class_double(File).as_stubbed_const }

    let(:file_utils_module) { class_double(FileUtils).as_stubbed_const }

    let(:plan_directory_pathname) { instance_double Object }

    let(:plan_pathname) { instance_double Object }

    let(:state_directory_pathname) { instance_double Object }

    let(:state_pathname) { instance_double Object }

    before do
      allow(provisioner).to receive(:[]).with(:plan).and_return plan_pathname

      allow(provisioner).to receive(:[]).with(:state).and_return state_pathname

      allow(file_class).to receive(:dirname).with(plan_pathname)
        .and_return plan_directory_pathname

      allow(file_class).to receive(:dirname).with(state_pathname)
        .and_return state_directory_pathname

      allow(file_utils_module).to create_plan_directory

      allow(file_utils_module).to create_state_directory
    end

    after { described_instance.create }

    subject { file_utils_module }

    it 'creates the parent directory of the plan file' do
      is_expected.to create_plan_directory
    end

    it 'creates the parent directory of the state file' do
      is_expected.to create_state_directory
    end
  end

  describe '#destroy(_state = nil)' do
    include_context '#provisioner'

    let :allow_current_state do
      allow(described_instance).to receive(:current_state).with no_args
    end

    let :allow_exist? do
      allow(file_class).to receive(:exist?).with provisioner_state
    end

    let(:file_class) { class_double(File).as_stubbed_const }

    let(:apply_execution_plan) { receive(:apply_execution_plan).with no_args }

    let(:create) { receive(:create).with no_args }

    let(:download_modules) { receive(:download_modules).with no_args }

    let :plan_destructive_execution do
      receive(:plan_execution).with destroy: true
    end

    let :validate_configuration_files do
      receive(:validate_configuration_files).with no_args
    end

    subject { described_instance }

    context 'when the state does not exist' do
      before { allow_exist?.and_return false }

      it('takes no action') { is_expected.to_not apply_execution_plan }
    end

    context 'when the state does exist but is empty' do
      before do
        allow_exist?.and_return true

        allow_current_state.and_return ''
      end

      it('takes no action') { is_expected.to_not apply_execution_plan }
    end

    context 'when the state does exist and is not empty' do
      before do
        allow_exist?.and_return true

        allow_current_state.and_return 'foo'

        allow(described_instance).to create

        allow(described_instance).to validate_configuration_files

        allow(described_instance).to download_modules

        allow(described_instance).to plan_destructive_execution

        allow(described_instance).to apply_execution_plan
      end

      after { described_instance.destroy }

      it 'ensures the parent directories of the plan and state files exist' do
        is_expected.to create
      end

      it 'validates the configuration files' do
        is_expected.to validate_configuration_files
      end

      it('gets the dependency modules') { is_expected.to download_modules }

      it 'plans a destructive execution' do
        is_expected.to plan_destructive_execution
      end

      it('applies the execution plan') { is_expected.to apply_execution_plan }
    end
  end

  describe '#verify_dependencies' do
    let :allow_version do
      allow(described_instance).to receive(:version).with no_args
    end

    subject { proc { described_instance.verify_dependencies } }

    context 'when the installed version is 0.6.z' do
      before { allow_version.and_return 'v0.6.z' }

      it('an error is not raised') { is_expected.to_not raise_error }
    end

    context 'when the installed version is 0.7.z' do
      before { allow_version.and_return 'v0.7.z' }

      it('an error is not raised') { is_expected.to_not raise_error }
    end

    context 'when the installed version is not supported' do
      before { allow_version.and_return 'v0.8.z' }

      it 'an error is raised' do
        is_expected.to raise_error Kitchen::UserError,
                                   'Only Terraform versions 0.6.z and 0.7.z ' \
                                     'are supported'
      end
    end
  end
end
