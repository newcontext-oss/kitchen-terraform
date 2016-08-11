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

require 'terraform/configurable'

RSpec
  .shared_examples Terraform::Configurable do |key:, criteria:|
  let(:instance) { instance_double Kitchen::Instance }

  describe "configuration option #{key}" do
    describe 'value requirements' do
      let :config do
        { key => value, kitchen_root: '/root', test_base_path: '/test' }
      end

      let(:suite) { instance_double Kitchen::Suite }

      before do
        allow(instance).to receive(:suite).with(no_args).and_return suite

        allow(instance).to receive(:to_str).with(no_args).and_return instance
          .to_s

        allow(suite).to receive(:name).with(no_args).and_return 'suite'
      end

      subject { proc { described_instance.finalize_config! instance } }

      context "when the provided value is #{criteria}" do
        let(:value) { valid_value }

        it 'does not raise a user error' do
          is_expected.to_not raise_error
        end
      end

      context "when the provided value is not #{criteria}" do
        let(:value) { invalid_value }

        it 'does raise a user error' do
          is_expected.to raise_error Kitchen::UserError, error_message
        end
      end
    end

    describe 'default value' do
      subject { described_instance[key] }

      it { is_expected.to default }
    end
  end
end
