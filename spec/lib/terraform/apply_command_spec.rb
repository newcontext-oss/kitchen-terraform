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

require "pathname"
require "support/terraform/command_examples"
require "terraform/apply_command"

::RSpec.describe ::Terraform::ApplyCommand do
  let :described_instance do described_class.new target: "target" do |options| options.state_out = "state-out" end end

  let :prepare_input_file do instance_double ::Terraform::PrepareInputFile end

  let :prepare_output_file do instance_double ::Terraform::PrepareOutputFile end

  before do
    allow(::Terraform::PrepareInputFile)
      .to receive(:new).with(file: ::Pathname.new("target")).and_return prepare_input_file

    allow(::Terraform::PrepareOutputFile)
      .to receive(:new).with(file: ::Pathname.new("state-out")).and_return prepare_output_file
  end

  it_behaves_like "#name" do let :name do "apply" end end

  describe "#prepare" do
    before do
      allow(prepare_input_file).to receive(:execute).with no_args

      allow(prepare_output_file).to receive(:execute).with no_args
    end

    after do described_instance.prepare end

    context "the input target file" do
      subject do prepare_input_file end

      it "is prepared" do is_expected.to receive(:execute).with no_args end
    end

    context "the output state file" do
      subject do prepare_output_file end

      it "is prepared" do is_expected.to receive(:execute).with no_args end
    end
  end
end
