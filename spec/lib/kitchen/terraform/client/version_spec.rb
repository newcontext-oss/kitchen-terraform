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
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/execute_command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Version do
  describe ".call" do
    subject do
      described_class.call cli: "cli",
                           logger: [],
                           timeout: 1234
    end

    context "when the Terraform version command results in failure" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "version"

      it do
        is_expected.to result_in_failure.with_the_value /Unable to parse Terraform client version output.*cli version/m
      end
    end

    context "when the value of the Terraform version command result does not match the expected format of 'vX.Y'" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "version",
                                                                    exit_code: 0

      it do
        is_expected.to result_in_failure
          .with_the_value /Unable to parse Terraform client version output.*output did not match 'vX.Y'/m
      end
    end

    context "when the value of the Terraform version command result does match the expected format of 'vX.Y'" do
      include_context "Kitchen::Terraform::Client::ExecuteCommand", command: "version",
                                                                    exit_code: 0,
                                                                    output: "Terraform v1.2.3\n\nSupplementary text!"

      it "should result in success with the value X.Y" do
        is_expected.to result_in_success.with_the_value 1.2
      end
    end
  end
end
