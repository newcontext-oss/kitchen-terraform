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

require 'terraform/file_configs'

::RSpec.shared_examples ::Terraform::FileConfigs do
  describe '#configure_files' do
    describe '[:plan]' do
      subject { described_instance[:plan] }

      it 'is defaulted to "terraform.tfplan"' do
        is_expected.to include 'terraform.tfplan'
      end
    end

    describe '[:state]' do
      subject { described_instance[:state] }

      it 'is defaulted to "terraform.tfstate"' do
        is_expected.to include 'terraform.tfstate'
      end
    end
  end
end
