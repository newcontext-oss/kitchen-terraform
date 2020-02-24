# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "kitchen/terraform/command_executor"
require "kitchen/terraform/command/output"
require "kitchen/terraform/outputs_reader"
require "mixlib/shellout"

::RSpec.describe ::Kitchen::Terraform::OutputsReader do
  subject do
    described_class.new command_executor: command_executor
  end

  let :command_executor do
    instance_double ::Kitchen::Terraform::CommandExecutor
  end

  describe "read" do
    let :command do
      instance_double ::Kitchen::Terraform::Command::Output
    end

    let :options do
      {}
    end

    context "when the output command fails due to an unexpected error" do
      before do
        allow(command_executor).to receive(:run).with(command: command, options: options).and_raise(
          ::Kitchen::TransientFailure,
          "unexpected"
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.read command: command, options: options
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when the output command fails due to no outputs defined" do
      let :error do
        ::Kitchen::TransientFailure.new "command failed", ::Mixlib::ShellOut::ShellCommandFailed.new(
          "no outputs defined"
        )
      end

      before do
        allow(command_executor).to receive(:run).with(command: command, options: options).and_raise error
      end

      specify "should yield an empty JSON object" do
        expect do |block|
          subject.read command: command, options: options, &block
        end.to yield_with_args json_outputs: "{}"
      end
    end

    context "when the output command succeeds" do
      let :standard_output do
        "{\"key\": \"value\"}"
      end

      before do
        allow(command_executor).to receive(:run).with(command: command, options: options).and_yield(
          standard_output: standard_output,
        )
      end

      specify "should yield the standard output" do
        expect do |block|
          subject.read command: command, options: options, &block
        end.to yield_with_args json_outputs: standard_output
      end
    end
  end
end
