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

require 'terraform/color_switch'

RSpec.shared_context '#color' do
  let(:color) { instance_double Object }

  before do
    allow(described_instance).to receive(:color).with(no_args)
      .and_return color
  end
end

RSpec.shared_examples Terraform::ColorSwitch do
  include_context '#color'

  describe '#color_switch' do
    subject { described_instance.color_switch }

    context 'when color is true' do
      it 'returns nothing' do
        is_expected.to eq ''
      end
    end

    context 'when color is false' do
      let(:color) { false }

      it 'returns -no-color' do
        is_expected.to eq ' -no-color'
      end
    end
  end
end
