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

require 'support/raise_error_examples'
require 'support/terraform/configurable_context'
require 'terraform/simple_coercer'

::RSpec.describe ::Terraform::SimpleCoercer do
  include_context 'instance'

  let :described_instance do
    described_class.new configurable: provisioner, expected: 'an integer',
                        method: method(:Integer)
  end

  describe '#coerce' do
    context 'when the value can be coerced by the method' do
      before { described_instance.coerce attr: :attr, value: 1 }

      subject { provisioner[:attr] }

      it('assigns the coerced value') { is_expected.to eq 1 }
    end

    context 'when the value can not be coerced by the method' do
      it_behaves_like 'a user error has occurred' do
        let :described_method do
          described_instance.coerce attr: :attr, value: 'foo'
        end

        let(:message) { /:attr.*an integer/ }
      end
    end
  end
end
