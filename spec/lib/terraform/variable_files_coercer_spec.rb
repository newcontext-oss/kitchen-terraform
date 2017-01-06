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

require 'terraform/variable_files_coercer'

::RSpec.describe ::Terraform::VariableFilesCoercer do
  let(:configurable) { {} }

  let(:described_instance) { described_class.new configurable: configurable }

  describe '#coerce' do
    context 'when the value is not an array' do
      before { described_instance.coerce attr: :attr, value: 'value' }

      subject { configurable[:attr] }

      it('coerces the value to be an array') { is_expected.to eq ['value'] }
    end
  end
end
