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
    describe "running `terraform version`" do
      before do
        allow(described_class).to receive(:run_command).and_return "Terraform v0.11.10"
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

      after do
        described_class.run do |version:| end
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
          described_class.run
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
          described_class.run
        end.to result_in_failure.with_message "unexpected error"
      end
    end

    describe "initializing an instance" do
      before do
        allow(described_class).to receive(:run_command).and_return "Terraform v1.2.3"
      end

      specify "should run `terraform version` and return an instance" do
        expect do |block|
          described_class.run(&block)
        end.to yield_with_args version: kind_of(::Kitchen::Terraform::Command::Version)
      end

      specify "should run `terraform version` and initialize the instance with the output" do
        expect(
          described_class.run do |version:| end.version
        ).to eq "1.2.3"
      end
    end
  end

  describe ".logger" do
    specify "should return the Kitchen logger" do
      expect(described_class.logger).to be ::Kitchen.logger
    end
  end

  describe ".superclass" do
    specify "should be Gem::Version" do
      expect(described_class.superclass).to be ::Gem::Version
    end
  end
end
