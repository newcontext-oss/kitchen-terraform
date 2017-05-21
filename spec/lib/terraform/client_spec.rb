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

require "support/terraform/configurable_context"
require "support/yield_control_examples"
require "terraform/client"

::RSpec.describe ::Terraform::Client do
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
    let :apply_shell_out do instance_double ::Terraform::ShellOut end

    before do
      provisioner[:apply_timeout] = 1234

      allow(::Terraform::ShellOut).to receive(:new)
        .with(cli: duck_type(:to_s), command: kind_of(::Terraform::ApplyCommand), logger: duck_type(:<<), timeout: 1234)
        .and_return apply_shell_out

      allow(apply_shell_out).to receive(:execute).with no_args
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
      before do allow(described_instance).to receive(:execute).with command: kind_of(::Terraform::Command) end

      subject do apply_shell_out end

      it "is executed" do is_expected.to receive(:execute).with no_args end
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

  describe "#output" do
    subject do described_instance.output end

    context "when outputs are defined" do
      include_context "outputs are defined"

      let :output_value do ::JSON.dump "name1" => {"value" => "value1"}, "name2" => {"value" => "value2"} end

      it "returns the hash" do is_expected.to eq("name1" => "value1", "name2" => "value2") end
    end

    context "when outputs are not defined" do
      include_context "outputs are not defined"

      it "returns empty hash" do is_expected.to eq({}) end
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

  describe "#output_search" do
    subject do described_instance.output_search name: "name" end

    context "when outputs are defined" do
      include_context "outputs are defined"

      let :output_value do ::JSON.dump "value" => "value" end

      it "returns the output value" do is_expected.to eq "value" end
    end

    context "when outputs are not defined" do
      include_context "outputs are not defined"

      it "returns an empty string" do is_expected.to eq("") end
    end
  end

  describe "#version" do
    before do
      allow(described_instance)
        .to receive(:execute).with(command: kind_of(::Terraform::VersionCommand)).and_yield "Terraform v0.9.0"
    end

    subject do described_instance.version end

    it "returns the version" do is_expected.to eq "0.9.0" end
  end
end
