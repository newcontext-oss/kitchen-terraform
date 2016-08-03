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
require 'terraform/error'
require 'support/terraform/client_holder_context'
require 'support/terraform/client_holder_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Provisioner::Terraform do
  let(:config) { { kitchen_root: kitchen_root } }

  let(:described_instance) { described_class.new config }

  let(:kitchen_root) { '<kitchen_root>' }

  it_behaves_like Terraform::ClientHolder

  it_behaves_like 'versions are set'

  describe '#[](attr)' do
    context 'when accessing the default :apply_timeout' do
      subject { described_instance[:apply_timeout] }

      it('returns 600 seconds') { is_expected.to be 600 }
    end
  end

  describe '#call(_state = nil)' do
    include_context '#client'

    let(:call_method) { described_instance.call }

    context 'when the configuration can be applied' do
      before do
        allow(client).to receive(:validate_configuration_files).with no_args

        allow(client).to receive(:download_modules).with no_args

        allow(client).to receive(:plan_execution).with no_args

        allow(client).to receive(:apply_execution_plan).with no_args
      end

      after { call_method }

      subject { client }

      it 'validates the configuration files' do
        is_expected.to receive(:validate_configuration_files).with no_args
      end

      it 'downloads the modules' do
        is_expected.to receive(:download_modules).with no_args
      end

      it 'plans the execution' do
        is_expected.to receive(:plan_execution).with no_args
      end

      it 'applies the execution plan' do
        is_expected.to receive(:apply_execution_plan).with no_args
      end
    end

    context 'when the configuration can not be applied due to failed command' do
      before do
        allow(client).to receive(:validate_configuration_files)
          .and_raise Terraform::Error
      end

      subject { proc { call_method } }

      it('raises an error') { is_expected.to raise_error Kitchen::ActionFailed }
    end
  end

  describe '#directory' do
    subject { described_instance.directory.to_s }

    it 'defaults to the Test Kitchen root directory' do
      is_expected.to eq kitchen_root
    end
  end

  describe '#finalize_config!(instance)' do
    context 'when the config has an empty :apply_timeout' do
      let(:config) { { apply_timeout: '' } }

      let(:instance) { Kitchen::Instance.new }

      subject { proc { described_instance.finalize_config! instance } }

      it('raises an error') { is_expected.to raise_error Kitchen::ClientError }
    end
  end

  describe '#kitchen_root' do
    subject { described_instance.kitchen_root.to_s }

    it('is the Test Kitchen root directory') { is_expected.to eq kitchen_root }
  end

  describe '#variable_files' do
    subject { described_instance.variable_files }

    it('defaults to empty array') { is_expected.to eq [] }
  end

  describe '#variables' do
    subject { described_instance.variables }

    it('defaults to empty array') { is_expected.to eq [] }
  end
end
