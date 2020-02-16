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

require "kitchen"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command_executor"

::RSpec.describe ::Kitchen::Terraform::Command::Output do
  describe "#run" do
    subject do
      described_class.new config: config, logger: logger
    end

    let :client do
      "/client"
    end

    let :command_timeout do
      456
    end

    let :config do
      {
        client: client,
        command_timeout: command_timeout,
        root_module_directory: root_module_directory,
      }
    end

    let :command_executor do
      instance_double ::Kitchen::Terraform::CommandExecutor
    end

    let :logger do
      ::Kitchen::Logger.new
    end

    let :options do
      { cwd: root_module_directory, timeout: command_timeout }
    end

    let :root_module_directory do
      "/root-module"
    end

    before do
      allow(::Kitchen::Terraform::CommandExecutor).to receive(:new).with(client: client, logger: logger).and_return(
        command_executor
      )
    end

    context "when running the command results in failure for unknown reasons" do
      before do
        allow(command_executor).to receive(:run).with(command: /output/, options: options).and_raise(
          ::Kitchen::ShellOut::ShellCommandFailed, "shell command failed"
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command results in failure because there are no outputs defined" do
      before do
        allow(command_executor).to receive(:run).with(command: /output/, options: options).and_raise(
          ::Kitchen::ShellOut::ShellCommandFailed, "no outputs defined"
        )
      end

      specify "should yield an empty hash" do
        expect do |block|
          subject.run(&block)
        end.to yield_with_args outputs: {}
      end
    end

    context "when running the command results in success but the output is invalid" do
      before do
        allow(command_executor).to receive(:run).with(command: "output -json", options: options).and_yield standard_output: "\"key\" = \"value\""
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command results in success" do
      let :standard_output do
        "{ \"output_name\": { \"sensitive\": false, \"type\": \"list\", \"value\": [\"output_value_1\"] } }"
      end

      before do
        allow(command_executor).to receive(:run).with(command: "output -json", options: options).and_yield(
          standard_output: standard_output,
        )
      end

      specify "should yield the outputs" do
        expect do |block|
          subject.run(&block)
        end.to yield_with_args outputs: { "output_name" => { "sensitive" => false, "type" => "list", "value" => ["output_value_1"] } }
      end
    end
  end
end
