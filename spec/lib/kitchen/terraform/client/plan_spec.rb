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

require "kitchen/terraform/client/plan"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Plan do
  describe ".call" do
    let :result do
      described_class.call cli: "cli",
                           logger: [],
                           options: {},
                           root_module: "root_module",
                           timeout: 1234
    end

    context "when the command execution is a failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "plan"

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
          is_expected.to match /cli plan.*-input=false/
        end
      end
    end

    context "when the command execution is a success" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "plan",
                      exit_code: 0

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

        it "is the output" do
          is_expected.to match /output/
        end
      end
    end
  end
end
