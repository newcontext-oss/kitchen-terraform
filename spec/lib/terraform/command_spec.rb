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

require 'terraform/command'

RSpec.describe Terraform::Command do
  let :described_instance do
    described_class.new options: options, target: target
  end

  let(:options) { instance_double Object }

  let(:target) { instance_double Object }

  describe '.new' do
    subject { ->(block) { described_class.new(&block) } }

    it 'yields command options for configuration' do
      is_expected.to yield_with_args Terraform::CommandOptions
    end
  end

  describe '#if_requirements_not_met' do
    subject { ->(block) { described_instance.if_requirements_not_met(&block) } }

    it('does not yield') { is_expected.to_not yield_control }
  end

  describe '#name' do
    subject { described_instance.name }

    it('is "help"') { is_expected.to eq 'help' }
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it 'is "terraform <name> <options> <target>"' do
      is_expected.to eq "terraform help #{options} #{target}"
    end
  end
end
