# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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
require 'terraform/apply_command'

::RSpec.describe ::Terraform::ApplyCommand do
  let :described_instance do
    described_class.new(target: 'target') { |options| options.state_out = 'state-out' }
  end

  let(:prepare_input_file) { instance_double ::Terraform::PrepareInputFile }

  let(:prepare_output_file) { instance_double ::Terraform::PrepareOutputFile }

  before do
    allow(::Terraform::PrepareInputFile)
      .to receive(:new).with(file: 'target').and_return prepare_input_file

    allow(::Terraform::PrepareOutputFile)
      .to receive(:new).with(file: 'state-out').and_return prepare_output_file
  end

  it_behaves_like('#name') { let(:name) { 'apply' } }

  describe '#prepare' do
    before do
      allow(prepare_input_file).to receive(:execute).with no_args

      allow(prepare_output_file).to receive(:execute).with no_args
    end

    after { described_instance.prepare }

    context 'the input target file' do
      subject { prepare_input_file }

      it('is prepared') { is_expected.to receive(:execute).with no_args }
    end

    context 'the output state file' do
      subject { prepare_output_file }

      it('is prepared') { is_expected.to receive(:execute).with no_args }
    end
  end
end
