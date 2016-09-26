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

require 'support/terraform/command_extender_examples'
require 'support/terraform/zero_seven_output_examples'
require 'support/terraform/zero_six_output_examples'
require 'terraform/output_command'

RSpec.describe Terraform::OutputCommand do
  let :described_instance do
    described_class.new list: list, version: version, state: state
  end

  let(:list) { instance_double Object }

  let(:state) { instance_double Object }

  let(:version) { '' }

  it_behaves_like Terraform::CommandExtender

  it_behaves_like(Terraform::ZeroSevenOutput) { let(:version) { 'v0.7' } }

  it_behaves_like(Terraform::ZeroSixOutput) { let(:version) { 'v0.6' } }

  describe '#name' do
    subject { described_instance.name }

    it('returns "output"') { is_expected.to eq 'output' }
  end
end
