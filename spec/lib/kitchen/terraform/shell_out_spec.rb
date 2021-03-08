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
require "kitchen/terraform/shell_out"
require "mixlib/shellout"

::RSpec.describe ::Kitchen::Terraform::ShellOut do
  subject do
    described_class.new command: command, logger: logger, options: { option_key: "option_value" }
  end

  let :command do
    "./client test"
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :shell_out do
    instance_double ::Mixlib::ShellOut
  end

  before do
    allow(::Mixlib::ShellOut).to receive(:new).with(
      command,
      {
        environment: { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true" },
        live_stream: logger,
        option_key: "option_value",
      }
    ).and_return shell_out
    allow(shell_out).to receive(:command).and_return command
    allow(shell_out).to receive(:cwd).and_return "/test"
    allow(shell_out).to receive(:execution_time).and_return 456
    allow(shell_out).to receive(:exitstatus).and_return 1
    allow(shell_out).to receive(:timeout).and_return 123
  end

  describe "#run" do
    context "when running the command fails due to an access error" do
      before do
        allow(shell_out).to receive(:run_command).and_raise ::Errno::EACCES
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command fails due to a no entry error" do
      before do
        allow(shell_out).to receive(:run_command).and_raise ::Errno::ENOENT
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command fails due to a timeout error" do
      before do
        allow(shell_out).to receive(:run_command).and_raise ::Mixlib::ShellOut::CommandTimeout
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command fails due to a non-zero exit code" do
      before do
        allow(shell_out).to receive :run_command
        allow(shell_out).to receive(:error!).and_raise ::Mixlib::ShellOut::ShellCommandFailed
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command succeeds" do
      let :standard_output do
        "stdout"
      end

      before do
        allow(shell_out).to receive :run_command
        allow(shell_out).to receive :error!
        allow(shell_out).to receive(:stdout).and_return standard_output
      end

      specify "should yield the standard output" do
        expect do |block|
          subject.run(&block)
        end.to yield_with_args standard_output: standard_output
      end
    end
  end
end
