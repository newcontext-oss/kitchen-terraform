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

require 'terraform/directory_config'

RSpec.shared_examples Terraform::DirectoryConfig do
  describe '#finalize_config!(instance)' do
    include_context 'finalize_config! instance'

    describe '[:directory]' do
      subject { described_instance[:directory] }

      it('defaults to the Kitchen root') { is_expected.to eq kitchen_root }
    end
  end
end
