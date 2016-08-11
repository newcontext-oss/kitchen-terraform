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
require 'support/terraform/configurable_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Provisioner::Terraform do
  let(:config) { { kitchen_root: kitchen_root } }

  let(:described_instance) { described_class.new config }

  let(:kitchen_root) { '<kitchen_root>' }

  it_behaves_like Terraform::ClientHolder

  it_behaves_like Terraform::Configurable, key: :apply_timeout,
                                           criteria: 'interpretable as an ' \
                                                       'integer' do
    let(:default) { be 600 }

    let(:invalid_value) { 'ten' }

    let(:error_message) { /an integer/ }

    let(:valid_value) { 1000 }
  end

  it_behaves_like Terraform::Configurable,
                  key: :directory, criteria: 'interpretable as an existing ' \
                                               'directory pathname' do
    let(:default) { be kitchen_root }

    let(:invalid_value) { '/non/existent' }

    let(:error_message) { /an existing directory/ }

    let(:valid_value) { '/existent' }

    before do
      allow(File).to receive(:directory?).with(invalid_value).and_return false

      allow(File).to receive(:directory?).with(valid_value).and_return true
    end
  end

  it_behaves_like Terraform::Configurable, key: :variable_files,
                                           criteria: 'interpretable as a ' \
                                                       'list of existing ' \
                                                       'file pathnames' do
    let(:default) { be_empty }

    let(:invalid_value) { ['/non_existent'] }

    let(:error_message) { /existing file pathnames/ }

    let(:valid_value) { ['/existent'] }

    before do
      allow(File).to receive(:file?).with(invalid_value.first).and_return false

      allow(File).to receive(:file?).with(valid_value.first).and_return true
    end
  end

  it_behaves_like Terraform::Configurable, key: :variables,
                                           criteria: 'interpretable as a ' \
                                                       'list of variable ' \
                                                       'assignments' do
    let(:default) { be_empty }

    let(:invalid_value) { ['-invalid'] }

    let(:error_message) { /variable assignments/ }

    let(:valid_value) { ['-foo-bar=biz'] }
  end

  it_behaves_like 'versions are set'

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
end
