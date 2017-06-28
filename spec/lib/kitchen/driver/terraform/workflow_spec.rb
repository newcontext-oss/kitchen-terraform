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
require "support/dry/monads/either_matchers"
require "support/kitchen/driver/terraform/workflow_context"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/client/execute_command_context"
require "support/kitchen/terraform/create_directories_context"

::RSpec.describe ::Kitchen::Driver::Terraform::Workflow do
  describe ".call" do
    include_context ::Kitchen::Instance

    subject do
      described_class.call config: driver.send(:config),
                           logger: driver.send(:logger)
    end

    before do
      driver.finalize_config! instance
    end

    context "when the create directories function results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories"

      it do
        is_expected.to result_in_failure.with_the_value kind_of ::String
      end
    end

    context "when the validate command results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories", failure: false

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "validate"

      it do
        is_expected.to result_in_failure.with_the_value /terraform validate/
      end
    end

    context "when the get command results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories", failure: false

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "validate",
                                                                    exit_code: 0

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "get"

      it do
        is_expected.to result_in_failure.with_the_value /terraform get/
      end
    end

    context "when the plan command results in failure" do
      include_context "Kitchen::Terraform::CreateDirectories", failure: false

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "validate",
                                                                    exit_code: 0

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "get",
                                                                    exit_code: 0

      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "plan"

      it do
        is_expected.to result_in_failure.with_the_value /terraform plan/
      end
    end

    context "when the apply command results in failure" do
      include_context "Kitchen::Driver::Terraform::Workflow"

      it do
        is_expected.to result_in_failure.with_the_value /driver workflow was a failure.*terraform apply/m
      end
    end

    context "when all commands result in success" do
      include_context "Kitchen::Driver::Terraform::Workflow", failure: false

      it do
        is_expected.to result_in_success.with_the_value "driver workflow was a success"
      end
    end
  end
end
