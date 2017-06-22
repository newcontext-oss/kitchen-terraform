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

require "kitchen/terraform/client/version"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Version do
  describe ".call" do
    let :result do
      described_class.call cli: "cli",
                           logger: [],
                           timeout: 1234
    end

    context "when the Terraform version command result is a failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "version"

      describe "the result" do
        subject do
          result
        end

        it "is a failure" do
          is_expected.to be_failure
        end
      end

      describe "the result's value" do
        subject do
          result.value
        end

        it "describes the failure" do
          is_expected.to match /Unable to parse Terraform client version output.*cli version/m
        end
      end
    end

    context "when the Terraform version command result's value is unexpected" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "version",
                      exit_code: 0

      describe "the result" do
        subject do
          result
        end

        it "is a failure" do
          is_expected.to be_failure
        end
      end

      describe "the result's value" do
        subject do
          result.value
        end

        it "describes the failure" do
          is_expected.to match /Unable to parse Terraform client version output.*output did not match 'vX.Y'/m
        end
      end
    end

    context "when the output matches the expected format" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "version",
                      exit_code: 0,
                      output: "Terraform v1.2.3\n\nSupplementary text!"

      describe "the result" do
        subject do
          result
        end

        it "is a success" do
          is_expected.to be_success
        end
      end

      describe "the result's value" do
        subject do
          result.value
        end

        it "is a float representing the client's major and minor versions" do
          is_expected.to eq 1.2
        end
      end
    end
  end
end
