# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "kitchen/terraform/client"
require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes do
  describe ".call" do
    include_context ::Kitchen::Instance

    let :group do
      {}
    end

    let :result do
      described_class.call driver: driver,
                           group: group,
                           terraform_state: "terraform_state"
    end

    before do
      driver.finalize_config! instance
    end

    context "when the Terraform output command result is a failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "output"

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
          is_expected.to match /configuring InSpec runner attributes failed.*terraform output/m
        end
      end
    end

    context "when the Terraform output command result's value is unexpected" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "output",
                      exit_code: 0,
                      output: ::JSON.generate(
                        "name" => {
                          "unexpected" => "value"
                        }
                      )

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
          is_expected.to match /configuring InSpec runner attributes failed.*\"value\"/m
        end
      end
    end

    context "when the group attribute output names do not match the Terraform output command result's value" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "output",
                      exit_code: 0,
                      output: ::JSON.generate(
                        "output_name" => {
                          "value" => "output_name value"
                        }
                      )

      let :group do
        {
          attributes: {
            attribute_name: "not_output_name"
          }
        }
      end

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
          is_expected.to match /configuring InSpec runner attributes failed.*\"not_output_name\"/m
        end
      end
    end

    context "when the group attribute output names match the Terraform output command result's value" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "output",
                      exit_code: 0,
                      output: ::JSON.generate(
                        "output_name" => {
                          "value" => "output_name value"
                        }
                      )

      let :group do
        {
          attributes: {
            attribute_name: "output_name"
          }
        }
      end

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

        it "is the attribute hash" do
          is_expected.to eq "attribute_name" => "output_name value",
                            "output_name" => "output_name value",
                            "terraform_state" => "terraform_state"
        end
      end
    end
  end
end
