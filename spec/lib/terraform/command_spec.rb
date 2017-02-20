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

require 'support/terraform/command_examples'
require 'terraform/command'

::RSpec.describe ::Terraform::Command do
  let(:described_instance) { described_class.new target: target }

  let(:options) { ::Terraform::CommandOptions.new }

  let(:target) { object }

  before do
    allow(::Terraform::CommandOptions)
      .to receive(:new).with(no_args).and_return options
  end

  it_behaves_like('#name') { let(:name) { 'help' } }

  describe '.new' do
    subject { ->(block) { described_class.new(&block) } }

    it 'yields command options for configuration' do
      is_expected.to yield_with_args Terraform::CommandOptions
    end
  end

  describe '#prepare' do
    subject { described_instance }

    it('takes no action') { is_expected.to respond_to :prepare }
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it 'is "<name> <options> <target>"' do
      is_expected.to eq "help #{options} #{target}"
    end
  end
end
