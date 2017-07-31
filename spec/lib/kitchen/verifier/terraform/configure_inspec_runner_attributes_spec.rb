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
require "support/dry/monads/either_matchers"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/client/command_context"

::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes do
  describe ".call" do
    include_context ::Kitchen::Instance

    let :group do
      {}
    end

    before do
      driver.finalize_config! instance
    end

    subject do
      described_class.call driver: driver,
                           group: group,
                           terraform_state: "terraform_state"
    end

    context "when the Terraform output command results in failure" do
      include_context "Kitchen::Terraform::Client::Command", subcommand: "output"

      it do
        is_expected.to result_in_failure
          .with_the_value /configuring Inspec::Runner attributes failed.*terraform output/m
      end
    end

    context "when the value of the Terraform output command result is unexpected" do
      include_context "Kitchen::Terraform::Client::Command",
                       exit_code: 0,
                       output_contents: ::JSON.generate(
                         "name" => {
                           "unexpected" => "value"
                         }
                       ),
                       subcommand: "output"

      it do
        is_expected.to result_in_failure.with_the_value /configuring Inspec::Runner attributes failed.*\"value\"/m
      end
    end

    context "when the group attribute output names do not match the value of the Terraform output command result" do
      include_context "Kitchen::Terraform::Client::Command",
                      exit_code: 0,
                      output_contents: ::JSON.generate(
                        "output_name" => {
                          "value" => "output_name value"
                        }
                      ),
                      subcommand: "output"

      let :group do
        {
          attributes: {
            attribute_name: "not_output_name"
          }
        }
      end

      it do
        is_expected.to result_in_failure
          .with_the_value /configuring Inspec::Runner attributes failed.*\"not_output_name\"/m
      end
    end

    context "when the group attribute output names match the value of the Terraform output command result" do
      include_context "Kitchen::Terraform::Client::Command",
                      exit_code: 0,
                      output_contents: ::JSON.generate(
                        "output_name" => {
                          "value" => "output_name value"
                        }
                      ),
                      subcommand: "output"

      let :group do
        {
          attributes: {
            attribute_name: "output_name"
          }
        }
      end

      it do
        is_expected.to result_in_success.with_the_value "attribute_name" => "output_name value",
                                                        "output_name" => "output_name value",
                                                        "terraform_state" => "terraform_state"
      end
    end
  end
end
