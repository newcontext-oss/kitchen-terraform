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

require "kitchen/terraform/client/output"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Output do
  describe ".call" do
    subject do
      described_class.call cli: "cli",
                           logger: [],
                           options: {},
                           timeout: 1234
    end

    context "when the Terraform output command results in failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "output"

      it do
        is_expected.to result_in_failure.with_the_value /parsing Terraform client output as JSON failed\n.*cli output/
      end
    end

    context "when the value of the Terraform output command result does not match the expected format of JSON" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "output",
                                                                    exit_code: 0

      it do
        is_expected.to result_in_failure
          .with_the_value /parsing Terraform client output as JSON failed\n.*unexpected token/
      end
    end

    context "when the value of the Terraform output command result matches the expected format of JSON" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "output",
                                                                    exit_code: 0,
                                                                    output: <<-OUTPUT
{
    "output_name": {
        "sensitive": false,
        "type": "list",
        "value": [
            "output_value_1"
        ]
    }
}
                                                                    OUTPUT

      it do
        is_expected.to result_in_success.with_the_value "output_name" => {
                                                          "sensitive" => false,
                                                          "type" => "list",
                                                          "value" => [
                                                            "output_value_1"
                                                          ]
                                                        }
      end
    end
  end
end
