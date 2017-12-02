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

require "kitchen/verifier/terraform/enumerate_groups_and_hostnames"

::RSpec
  .describe ::Kitchen::Verifier::Terraform::EnumerateGroupsAndHostnames do
    describe ".call" do
      let :passed_block do
        lambda do |block|
          described_class
            .call(
              groups: [group],
              output: output,
              &block
            )
        end
      end

      context "when a group omits :hostnames" do
        subject do
          passed_block
        end

        let :group do
          {name: "name"}
        end

        it "is called with the group and 'localhost'" do
          is_expected
            .to(
              yield_with_args(
                group: group,
                hostname: "localhost"
              )
            )
        end
      end

      context "when the group associates :hostnames with an invalid Terraform output name" do
        subject do
          lambda do
            described_class
              .call(
                groups: [group],
                output: output
              ) do |group:, hostname:| end
          end
        end

        let :output do
          {
            "hostnames" => {
              "type" => "string",
              "value" => "hostname"
            }
          }
        end

        let :group do
          {hostnames: "invalid"}
        end

        it do
          is_expected
            .to(
              result_in_failure
                .with_message(
                  "Enumeration of groups and hostnames resulted in failure due to the omission of the configured " \
                    ":hostnames output or an unexpected output structure: key not found: \"invalid\""
                )
            )
        end
      end

      context "when the group associates :hostnames with a valid Terraform output name" do
        subject do
          passed_block
        end

        let :output do
          {
            "hostnames" => {
              "type" => "string",
              "value" => "hostname"
            }
          }
        end

        let :group do
          {hostnames: "hostnames"}
        end

        it "is called with the group and each resolved hostname" do
          is_expected
            .to(
              yield_with_args(
                group: group,
                hostname: "hostname"
              )
            )
        end
      end
    end
  end
