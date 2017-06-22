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

require "json"
require "kitchen/verifier/terraform/enumerate_groups_and_hostnames"
require "support/kitchen/terraform/client/execute_command_context"
require "support/kitchen/instance_context"

::RSpec.describe ::Kitchen::Verifier::Terraform::EnumerateGroupsAndHostnames do
  include_context ::Kitchen::Instance

  describe ".call" do
    before do
      driver.finalize_config! instance
    end

    let :passed_block do
      lambda do |block|
        described_class.call driver: driver, groups: [group], &block
      end
    end

    let :result do
      described_class.call driver: driver, groups: [group] do |group:, hostname:|
      end
    end

    context "when a group omits :hostnames" do
      let :group do
        {
          name: "name"
        }
      end

      describe "the passed block" do
        subject do
          passed_block
        end

        it "is called with the group and 'localhost'" do
          is_expected.to yield_with_args group: group, hostname: "localhost"
        end
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

        it "describes the success" do
          is_expected.to eq "finished enumeration of groups and hostnames"
        end
      end
    end

    context "when a group associates :hostnames with a string but the output command is a failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "output"

      let :group do
        {
          hostnames: "abc"
        }
      end

      describe "the passed block" do
        subject do
          passed_block
        end

        it "is not called" do
          is_expected.to_not yield_control
        end
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
          is_expected.to match /terraform output/
        end
      end
    end

    context "when the group associates :hostnames with an invalid Terraform output name" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "output",
                      exit_code: 0,
                      output: ::JSON.generate(
                        "hostnames" => {
                          "type" => "string",
                          "value" => "hostname"
                        }
                      )

      let :group do
        {
          hostnames: "invalid"
        }
      end

      describe "the passed block" do
        subject do
          passed_block
        end

        it "is not called" do
          is_expected.to_not yield_control
        end
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
          is_expected.to eq "key not found: \"invalid\""
        end
      end
    end

    context "when the group associates :hostnames with a valid Terraform output name" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand",
                      command: "output",
                      exit_code: 0,
                      output: ::JSON.generate(
                        "hostnames" => {
                          "type" => "string",
                          "value" => "hostname"
                        }
                      )

      let :group do
        {
          hostnames: "hostnames"
        }
      end

      describe "the passed block" do
        subject do
          passed_block
        end

        it "is called with the group and each resolved hostname" do
          is_expected.to yield_with_args group: group, hostname: "hostname"
        end
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

        it "describes the success" do
          is_expected.to eq "finished enumeration of groups and hostnames"
        end
      end
    end
  end
end
