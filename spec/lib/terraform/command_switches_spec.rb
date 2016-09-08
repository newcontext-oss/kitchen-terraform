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

require 'terraform/command_switches'
require 'support/terraform/command_switches_examples'

RSpec.describe Terraform::CommandSwitches do
  let(:logger) { instance_double Object }

  let(:described_instance) do
    described_class.new logger: logger, color: true
  end

  describe '#color_switch' do
    subject { described_instance.color_switch }

    it 'returns nothing' do
      is_expected.to eq ''
    end
  end

  let(:described_no_color_instance) do
    described_class.new logger: logger, color: false
  end

  describe '#color_switch' do
    subject { described_no_color_instance.color_switch }

    it 'returns "-no-color"' do
      is_expected.to eq ' -no-color'
    end
  end
end
