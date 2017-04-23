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

require 'terraform/integer_coercer'
require 'terraform/simple_config'

::RSpec.shared_examples ::Terraform::SimpleConfig do
  describe '#configure_required' do
    let(:coercer) { instance_double ::Terraform::IntegerCoercer }

    let(:configurable) { object }

    before do
      allow(described_class).to receive(:required_config)
        .with(:attr).and_yield object, 5678, configurable

      allow(::Terraform::IntegerCoercer)
        .to receive(:new).with(configurable: configurable).and_return coercer

      allow(coercer).to receive(:coerce).with attr: :attr, value: 5678
    end

    after do
      described_class
        .configure_required attr: :attr,
                            coercer_class: ::Terraform::IntegerCoercer,
                            default_value: 1234
    end

    describe 'configuring coercion' do
      subject { coercer }

      it 'configures coercion for the config attribute' do
        is_expected.to receive(:coerce).with attr: :attr, value: 5678
      end
    end

    describe 'setting a default value' do
      subject { described_class }

      it 'sets a default value' do
        is_expected.to receive(:default_config).with :attr, 1234
      end
    end
  end
end
