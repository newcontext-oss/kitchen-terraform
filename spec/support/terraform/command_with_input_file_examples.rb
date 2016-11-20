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

require 'terraform/command_with_input_file'

::RSpec.shared_examples ::Terraform::CommandWithInputFile do
  describe '#if_requirements_not_met' do
    subject { ->(block) { described_instance.if_requirements_not_met(&block) } }

    before do
      allow(::File).to receive(:exist?).with(described_instance.input_file)
        .and_return file_exist
    end

    context 'when the input file does exist' do
      let(:file_exist) { true }

      it('takes no action') { is_expected.to_not yield_control }
    end

    context 'when the input file does not exist' do
      let(:file_exist) { false }

      it 'yields the reason' do
        is_expected.to yield_with_args 'missing input file'
      end
    end
  end
end
