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
require 'support/raise_error_examples'
require 'support/terraform/configurable_context'

::RSpec.describe ::Terraform::VariablesCoercer do
  include_context 'instance'

  let(:described_instance) { described_class.new configurable: provisioner }

  describe '#coerce' do
    subject { coercer }

    context 'when the value is a string or list' do
      let(:coercer) { instance_double ::Terraform::DeprecatedVariablesCoercer }

      before do
        allow(::Terraform::DeprecatedVariablesCoercer)
          .to receive(:new).with(configurable: provisioner).and_return coercer
      end

      after { described_instance.coerce attr: :attr, value: 'foo=bar' }

      it 'uses a deprecated variables coercer' do
        is_expected.to receive(:coerce).with attr: :attr, value: 'foo=bar'
      end
    end

    context 'when the value is not a string or list' do
      let(:coercer) { instance_double ::Terraform::SimpleCoercer }

      before do
        allow(::Terraform::SimpleCoercer).to receive(:new).with(
          configurable: provisioner,
          expected: 'a mapping of Terraform variable assignments',
          method: described_instance.method(:Hash)
        ).and_return coercer
      end

      after { described_instance.coerce attr: :attr, value: { foo: :bar } }

      it 'uses a SimpleCoercer for a Hash' do
        is_expected.to receive(:coerce).with attr: :attr, value: { foo: :bar }
      end
    end
  end
end
