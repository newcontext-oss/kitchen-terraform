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

require "kitchen/verifier/terraform/configure_inspec_runner_attributes"

::RSpec
  .describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes do
    subject do
      described_class
    end

    describe ".call" do
      def call_method
        subject
          .call(
            group: group,
            options: options,
            output: output
          )
      end

      let :group do
        {}
      end

      let :options do
        {}
      end

      context "when the value of the Terraform output command result is unexpected" do
        let :output do
          {"name" => {"unexpected" => "value"}}
        end

        specify do
          expect do
            call_method
          end
            .to result_in_failure.with_message /Configuring InSpec runner attributes resulted in failure: .*\"value\"/
        end
      end

      context "when the group attribute output names do not match the value of the Terraform output command result" do
        let :group do
          {attributes: {attribute_name: "not_output_name"}}
        end

        let :output do
          {"output_name" => {"value" => "output_name value"}}
        end

        specify do
          expect do
            call_method
          end
            .to(
              result_in_failure
                .with_message(/Configuring InSpec runner attributes resulted in failure: .*\"not_output_name\"/)
            )
        end
      end

      context "when the group attribute output names match the value of the Terraform output command result" do
        let :group do
          {attributes: {attribute_name: "output_name"}}
        end

        let :output do
          {"output_name" => {"value" => "output_name value"}}
        end

        specify do
          expect do
            call_method
          end
            .to(
              change do
                options.dig :attributes
              end
                .to(
                  "attribute_name" => "output_name value",
                  "output_name" => "output_name value"
                )
            )
        end
      end
    end
  end
