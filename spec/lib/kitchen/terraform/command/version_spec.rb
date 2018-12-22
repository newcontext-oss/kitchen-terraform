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
require "kitchen/terraform/command/version"

::RSpec.describe ::Kitchen::Terraform::Command::Version do
  describe ".run" do
    let :timeout do
      1234
    end

    let :working_directory do
      "/working/directory"
    end

    describe "running `terraform version`" do
      specify "should run `terraform version` in the provided working directory" do
        expect(described_class).to receive(:run_command).with(
          "terraform version",
          including(cwd: working_directory),
        )
      end

      specify "should run `terraform version` in an environment which preserves the locale of the parent environment" do
        expect(described_class).to receive(:run_command).with(
          "terraform version",
          including(environment: including("LC_ALL" => nil)),
        )
      end

      specify "should run `terraform version` in an environment which optimizes Terraform for automation" do
        expect(described_class).to receive(:run_command).with(
          "terraform version",
          including(environment: including("TF_IN_AUTOMATION" => "true")),
        )
      end

      specify "should run `terraform version` in an environment which treats Terraform output errors as warnings" do
        expect(described_class).to receive(:run_command).with(
          "terraform version",
          including(environment: including("TF_WARN_OUTPUT_ERRORS" => "true")),
        )
      end

      specify "should run `terraform version` within the provided timeout" do
        expect(described_class).to receive(:run_command).with(
          "terraform version",
          including(timeout: timeout),
        )
      end

      after do
        described_class.run timeout: timeout, working_directory: working_directory
      end
    end

    describe "handling the failure of running `terraform version`" do
      before do
        allow(described_class).to receive(:run_command).and_raise(
          ::Kitchen::ShellOut::ShellCommandFailed, "shell command failed"
        )
      end

      specify "should result in failure with the failed command output" do
        expect do
          described_class.run timeout: timeout, working_directory: working_directory
        end.to result_in_failure.with_message "shell command failed"
      end
    end

    describe "handling an unexpected error" do
      before do
        allow(described_class).to receive(:run_command).and_raise(
          ::StandardError.new("unexpected error").extend(::Kitchen::Error)
        )
      end

      specify "should result in failure with the unexpected error message" do
        expect do
          described_class.run timeout: timeout, working_directory: working_directory
        end.to result_in_failure.with_message "unexpected error"
      end
    end

    describe "initializing an instance" do
      before do
        allow(described_class).to receive(:run_command).and_return "output"
      end

      specify "should run `terraform version` and return an instance" do
        expect(described_class.run(timeout: timeout, working_directory: working_directory)).to(
          be_a(::Kitchen::Terraform::Command::Version)
        )
      end
    end
  end
end
