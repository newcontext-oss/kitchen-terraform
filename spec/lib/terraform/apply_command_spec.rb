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

require 'terraform/apply_command'
require 'support/terraform/color_switch_examples'

RSpec.describe Terraform::ApplyCommand do
  include_context '#color'

  it_behaves_like Terraform::ColorSwitch

  let(:described_instance) do
    described_class.new color: color, logger: logger, state: state
  end

  let(:logger) { instance_double Object }

  let(:state) { instance_double Object }

  describe '#name' do
    subject { described_instance.name }

    it('returns "apply"') { is_expected.to eq 'apply' }
  end

  describe '#options' do
    subject { described_instance.options }

    it 'returns "-input=false -state=<state_pathname>"' do
      is_expected.to eq "-input=false -state=#{state}"
    end
  end
end
