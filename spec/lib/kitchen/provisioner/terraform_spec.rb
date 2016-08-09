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
    subject { described_instance[key] }

    context 'when accessing the default :apply_timeout' do
      let(:key) { :apply_timeout }

      it('returns 600 seconds') { is_expected.to be 600 }
    end

    context 'when accessing the default :directory' do
      let(:key) { :directory }

      it('returns <kitchen_root>') { is_expected.to be kitchen_root }
    end

    context 'when accessing the default :variable_files' do
      let(:key) { :variable_files }

      it('returns an empty collection') { is_expected.to be_empty }
    end

    context 'when accessing the default :variables' do
      let(:key) { :variables }

      it('returns an empty collection') { is_expected.to be_empty }
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

  describe '#finalize_config!(instance)' do
    let(:instance) { instance_double Kitchen::Instance }

    let(:non_existent) { '/non/existent' }

    before do
      allow(instance).to receive(:to_str).with(no_args).and_return instance.to_s
    end

    shared_examples 'a user error has occurred' do
      subject { proc { described_instance.finalize_config! instance } }

      it 'raises a user error' do
        is_expected.to raise_error Kitchen::UserError, message
      end
    end

    context 'when the config has a non-integer value for :apply_timeout' do
      it_behaves_like 'a user error has occurred' do
        let(:config) { { apply_timeout: 'six' } }

        let(:message) { /an integer/ }
      end
    end

    context 'when the config has a non-existent value for :directory' do
      it_behaves_like 'a user error has occurred' do
        let(:config) { { directory: non_existent } }

        let(:message) { /existing directory pathname/ }

        before do
          allow(File).to receive(:directory?).with(non_existent).and_return false
        end
      end
    end

    context 'when the config has a list of non-existent files for ' \
              ':variable_files' do
      it_behaves_like 'a user error has occurred' do
        let(:config) { { variable_files: [non_existent] } }

        let(:message) { /existing file pathnames/ }

        before do
          allow(File).to receive(:file?).with(non_existent).and_return false
        end
      end
    end

    context 'when the config has an invalid element in :variables' do
      it_behaves_like 'a user error has occurred' do
        let(:config) { { variables: ['-invalid'] } }

        let(:message) { /variable assignments/ }
      end
    end
  end
end
