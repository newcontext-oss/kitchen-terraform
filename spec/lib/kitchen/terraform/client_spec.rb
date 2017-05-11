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

require "json"
require "kitchen"
require "kitchen/terraform/client"
require "support/terraform/configurable_context"
require "support/yield_control_examples"
require "terraform/command"
require "terraform/destructive_plan_command"
require "terraform/get_command"
require "terraform/output_command"
require "terraform/plan_command"
require "terraform/shell_out"
require "terraform/show_command"
require "terraform/validate_command"

::RSpec.describe ::Kitchen::Terraform::Client do
  include_context "instance"

  let :described_instance do described_class.new config: provisioner, logger: ::Kitchen::Logger.new end

  shared_context "outputs are defined" do
    before do
      allow(described_instance)
        .to receive(:execute).with(command: kind_of(::Terraform::OutputCommand)).and_yield output_value
    end
  end

  shared_context "outputs are not defined" do
    before do
      allow(described_instance).to receive(:execute)
        .with(command: kind_of(::Terraform::OutputCommand)).and_raise ::Kitchen::StandardError, "no outputs"
    end
  end

  shared_examples "#apply" do
    before do
      provisioner[:apply_timeout] = 1234

      allow(::Kitchen::Terraform::Client::Apply).to receive(:call).with config: provisioner, logger: duck_type(:<<)
    end

    shared_examples "#execute" do |command|
      let :shell_out do instance_double ::Terraform::ShellOut end

      before do
        allow(described_instance).to receive(:execute).with command: kind_of(::Terraform::Command)

        allow(described_instance).to receive(:execute).with(command: kind_of(command_class)).and_call_original

        allow(::Terraform::ShellOut).to receive(:new)
          .with(cli: duck_type(:to_s), command: kind_of(command_class), logger: duck_type(:<<)).and_return shell_out
      end

      subject do shell_out end

      it "a #{command} command is executed" do is_expected.to receive(:execute).with no_args end
    end

    it_behaves_like "#execute", "validate" do let :command_class do ::Terraform::ValidateCommand end end

    it_behaves_like "#execute", "get" do let :command_class do ::Terraform::GetCommand end end

    it_behaves_like "#execute", "plan" do let :command_class do plan_command_class end end

    describe "the apply command" do
      before do
        allow(described_instance).to receive(:execute).with command: kind_of(::Terraform::Command)
      end

      subject do
        ::Kitchen::Terraform::Client::Apply
      end

      it "is executed" do
        is_expected.to receive(:call).with config: provisioner, logger: duck_type(:<<)
      end
    end
  end

  describe "#apply_constructively" do
    let :plan_command_class do ::Terraform::PlanCommand end

    after do described_instance.apply_constructively end

    it_behaves_like "#apply"
  end

  describe "#apply_destructively" do
    let :plan_command_class do ::Terraform::DestructivePlanCommand end

    after do described_instance.apply_destructively end

    it_behaves_like "#apply"
  end

  describe "#each_output_name" do
    subject do lambda do |block| described_instance.each_output_name &block end end

    context "when outputs are defined" do
      include_context "outputs are defined"

      let :output_value do ::JSON.dump "output_name_1" => "output_value_1", "output_name_2" => "output_value_2" end

      it "yields each output name" do is_expected.to yield_successive_args "output_name_1", "output_name_2" end
    end

    context "when outputs are not defined" do
      include_context "outputs are not defined"

      it "does not yield" do is_expected.to_not yield_control end
    end
  end

  describe "#iterate_output" do
    subject do lambda do |block| described_instance.iterate_output name: "name", &block end end

    context "when outputs are defined" do
      include_context "outputs are defined"

      let :output_value do ::JSON.dump "value" => ["value1", "value2"] end

      it "iterates the output values" do is_expected.to yield_successive_args "value1", "value2" end
    end

    context "when outputs are not defined" do
      include_context "outputs are not defined"

      it "does not yield" do is_expected.to_not yield_control end
    end
  end

  describe "#load_state" do
    let :described_method do :load_state end

    before do
      allow(described_instance).to receive(:execute).with(command: kind_of(::Terraform::ShowCommand)).and_yield state
    end

    context "when state does exist" do
      let :state do "state" end

      it_behaves_like "control is yielded"
    end

    context "when state does not exist" do
      let :state do "" end

      it_behaves_like "control is not yielded"
    end
  end

  describe "#output" do
    subject do described_instance.output name: "name" end

    context "when outputs are defined" do
      include_context "outputs are defined"

      let :output_value do ::JSON.dump "value" => "value" end

      it "returns the output value" do is_expected.to eq "value" end
    end

    context "when outputs are not defined" do
      include_context "outputs are not defined"

      it "returns an empty string" do is_expected.to eq "" end
    end
  end
end
