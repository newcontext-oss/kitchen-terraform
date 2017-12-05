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
      let :calling_the_method do
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
          calling_the_method
        end

        let :group do
          {name: "name"}
        end

        let :output do
          {}
        end

        it "yields the group and 'localhost'" do
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
              )
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
          calling_the_method
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

        it "yields the group and each resolved hostname" do
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
