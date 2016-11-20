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

require 'terraform/variables_coercer'
require 'support/terraform/configurable_context'

::RSpec.describe ::Terraform::VariablesCoercer do
  include_context 'instance'

  let(:described_instance) { described_class.new configurable: provisioner }

  describe '#coerce' do
    context 'when the value is a string or list' do
      before { described_instance.coerce attr: :attr, value: 'foo=bar' }

      subject { provisioner[:attr] }

      it 'coerces the value assuming the deprecated "name=value" format' do
        is_expected.to include 'foo' => 'bar'
      end
    end

    context 'when the value is not a string or list' do
      subject { proc { described_instance.coerce attr: :attr, value: 1 } }

      it 'coerces the value assuming a mapping' do
        is_expected.to raise_error ::Kitchen::UserError,
                                   /a mapping of Terraform variable assignments/
      end
    end
  end
end
