# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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
require "kitchen/errors"
require "kitchen/terraform/command/output"
require "kitchen/terraform/outputs_reader"
require "kitchen/terraform/transport/connection"

::RSpec.describe ::Kitchen::Terraform::OutputsReader do
  subject do
    described_class.new connection: connection
  end

  let :connection do
    instance_double ::Kitchen::Terraform::Transport::Connection
  end

  describe "read" do
    let :command do
      instance_double ::Kitchen::Terraform::Command::Output
    end

    context "when the output command fails due to an unexpected error" do
      specify "should raise a transient failure error" do
        allow(connection).to receive(:execute).with(command).and_raise ::Kitchen::StandardError.new("unexpected")

        expect do
          subject.read command: command
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when the output command fails due to no outputs defined" do
      specify "should yield an empty JSON object" do
        allow(connection).to receive(:execute).with(command).and_raise ::Kitchen::ShellOut::ShellCommandFailed
                                                                         .new("command failed", ::Kitchen::ShellOut::ShellCommandFailed.new("no outputs defined"))

        expect do |block|
          subject.read command: command, &block
        end.to yield_with_args json_outputs: "{}"
      end
    end

    context "when the output command succeeds" do
      let :standard_output do
        "{\"key\": \"value\"}"
      end

      specify "should yield the standard output" do
        allow(connection).to receive(:execute).with(command).and_return standard_output

        expect do |block|
          subject.read command: command, &block
        end.to yield_with_args json_outputs: standard_output
      end
    end
  end
end
