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

require "dry/monads"
require "kitchen/driver/terraform/workflow"
require "support/kitchen/driver/terraform/workflow_context"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Driver::Terraform::Workflow do
  describe ".call" do
    include_context ::Kitchen::Instance

    let :result do
      described_class.call config: driver.send(:config), logger: []
    end

    before do
      driver.finalize_config! instance
    end

    context "when the validate command fails" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "validate"

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
          is_expected.to match /terraform validate/
        end
      end
    end

    context "when the get command fails" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "validate", exit_code: 0

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "get"

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
          is_expected.to match /terraform get/
        end
      end
    end

    context "when the plan command fails" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "validate", exit_code: 0

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "get", exit_code: 0

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "plan"

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
          is_expected.to match /terraform plan/
        end
      end
    end

    context "when the apply command fails" do
      include_context "Kitchen::Driver::Terraform::Workflow"

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
          is_expected.to match /driver workflow was a failure.*terraform apply/m
        end
      end
    end

    context "when all commands succeed" do
      include_context "Kitchen::Driver::Terraform::Workflow", failure: false

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

        it "is the command output" do
          is_expected.to eq "driver workflow was a success"
        end
      end
    end
  end
end
