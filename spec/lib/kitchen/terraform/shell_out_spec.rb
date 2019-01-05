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

require "kitchen"
require "kitchen/terraform/shell_out"

::RSpec.describe ::Kitchen::Terraform::ShellOut do
  describe ".logger" do
    specify "should return the Kitchen logger" do
      expect(described_class.logger).to be ::Kitchen.logger
    end
  end

  describe ".run" do
    let :command do
      Class.new do
        def store(output:)
          output
        end

        def to_s
          "command"
        end
      end.new
    end

    let :command_string do
      "command"
    end

    describe "the default arguments" do
      specify "should include the current working directory" do
        expect(described_class).to receive(:run_command).with command_string, including(cwd: ::Dir.pwd)
      end

      specify "should include a 60,000 second timeout" do
        expect(described_class).to receive(:run_command).with command_string, including(timeout: 60_000)
      end

      after do
        described_class.run command: command
      end
    end

    describe "the environment" do
      specify "should preserve the locale of the parent environment" do
        expect(described_class).to receive(:run_command).with(
          command_string,
          including(environment: including("LC_ALL" => nil)),
        )
      end

      specify "should optimize Terraform for automation" do
        expect(described_class).to receive(:run_command).with(
          command_string,
          including(environment: including("TF_IN_AUTOMATION" => "1")),
        )
      end

      specify "should treat Terraform output errors as warnings" do
        expect(described_class).to receive(:run_command).with(
          command_string,
          including(environment: including("TF_WARN_OUTPUT_ERRORS" => "1")),
        )
      end

      after do
        described_class.run command: command
      end
    end

    describe "a command failure" do
      before do
        allow(described_class).to receive(:run_command).with(command_string, kind_of(::Hash)).and_raise(
          ::Kitchen::ShellOut::ShellCommandFailed, "shell command failed"
        )
      end

      specify "should result in failure with the failed command output" do
        expect do
          described_class.run command: command
        end.to result_in_failure.with_message "shell command failed"
      end
    end

    describe "an unexpected error" do
      before do
        allow(described_class).to receive(:run_command).with(command_string, kind_of(::Hash)).and_raise(
          ::StandardError.new("unexpected error").extend(::Kitchen::Error)
        )
      end

      specify "should result in failure with the unexpected error message" do
        expect do
          described_class.run command: command
        end.to result_in_failure.with_message "unexpected error"
      end
    end

    describe "the output" do
      let :output do
        "output"
      end

      before do
        allow(described_class).to receive(:run_command).with(command_string, kind_of(::Hash)).and_return output
      end

      specify "should be stored in the command" do
        expect(command).to receive(:store).with output: output
      end

      after do
        described_class.run command: command
      end
    end
  end
end
