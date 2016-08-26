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
require 'terraform/error'
require 'support/terraform/configurable_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Driver::Terraform do
  let(:described_instance) { described_class.new }

  it_behaves_like Terraform::Configurable

  it_behaves_like 'versions are set'

  describe '.serial_actions' do
    subject(:serial_actions) { described_class.serial_actions }

    it('is empty') { is_expected.to be_empty }
  end

  describe '#create(_state = nil)' do
    include_context '#provisioner'

    let :allow_validate do
      allow(provisioner).to receive(:validate_version).with no_args
    end

    subject { proc { described_instance.create } }

    context 'when the installed version of Terraform is supported' do
      before { allow_validate }

      it('raises no error') { is_expected.to_not raise_error }
    end

    context 'when the installed version of Terraform is not supported' do
      before { allow_validate.and_raise Terraform::Error }

      it 'raise an action failed error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end
  end

  describe '#destroy(_state = nil)' do
    include_context '#provisioner'

    let :allow_apply do
      allow(provisioner).to receive(:apply_execution_plan).with no_args
    end

    let(:call_method) { described_instance.destroy }

    before do
      allow(provisioner).to receive(:validate_configuration_files).with no_args

      allow(provisioner).to receive(:download_modules).with no_args

      allow(provisioner).to receive(:plan_destructive_execution).with no_args
    end

    context 'when the Terraform state can be destroyed' do
      before { allow_apply }

      after { call_method }

      subject { provisioner }

      it 'validates the configuration files' do
        is_expected.to receive(:validate_configuration_files).with no_args
      end

      it 'gets the modules' do
        is_expected.to receive(:download_modules).with no_args
      end

      it 'plans the destructive execution' do
        is_expected.to receive(:plan_destructive_execution).with no_args
      end

      it 'applies the execution plan' do
        is_expected.to receive(:apply_execution_plan).with no_args
      end
    end

    context 'when a provisioner command fails' do
      before { allow_apply.and_raise Terraform::Error }

      subject { proc { call_method } }

      it 'raises an error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end
  end
end
