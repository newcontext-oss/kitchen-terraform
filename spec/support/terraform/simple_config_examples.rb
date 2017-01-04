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
    let(:coercer) { instance_double coercer_class }

    let(:coercer_class) { ::Terraform::IntegerCoercer }

    let(:configurable) { object }

    before do
      allow(described_class).to receive(:required_config)
        .with(:attr).and_yield object, 'value', configurable

      allow(coercer_class)
        .to receive(:new).with(configurable: configurable).and_return coercer
    end

    after do
      described_class
        .configure_required attr: :attr, coercer_class: coercer_class
    end

    subject { coercer }

    it 'configures coercion for the config attribute' do
      is_expected.to receive(:coerce).with attr: :attr, value: 'value'
    end
  end
end
