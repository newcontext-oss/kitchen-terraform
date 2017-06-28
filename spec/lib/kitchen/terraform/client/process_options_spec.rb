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

require "kitchen/terraform/client/process_options"
require "support/dry/monads/either_matchers"

::RSpec.describe ::Kitchen::Terraform::Client::ProcessOptions do
  describe ".call" do
    context "when an unsupported option is processed" do
      subject do
        described_class.call unprocessed_options: {
                               unsupported_option: "unsupported_option"
                             }
      end

      it do
        is_expected.to result_in_failure
          .with_the_value /:unsupported_option is not a supported Terraform Client option/m
      end
    end

    context "when all options are processed" do
      subject do
        described_class.call unprocessed_options: options
      end

      shared_examples "a flag is produced" do |flag:|
        it do
          is_expected.to result_in_success.with_the_value including flag
        end
      end

      shared_examples "no flag is produced" do
        it do
          is_expected.to result_in_success.with_the_value []
        end
      end

      context "when the options associate :color with false" do
        let :options do
          {
            color: false
          }
        end

        it_behaves_like "a flag is produced", flag: "-no-color"
      end

      context "when the options associate :color with true" do
        let :options do
          {
            color: true
          }
        end

        it_behaves_like "no flag is produced"
      end

      context "when the options associate :destory with false" do
        let :options do
          {
            destroy: false
          }
        end

        it_behaves_like "no flag is produced"
      end

      context "when the options associate :destory with true" do
        let :options do
          {
            destroy: true
          }
        end

        it_behaves_like "a flag is produced", flag: "-destroy"
      end

      context "when the options associate :input with an object" do
        let :options do
          {
            input: "object"
          }
        end

        it_behaves_like "a flag is produced", flag: "-input=object"
      end

      context "when the options associate :json with false" do
        let :options do
          {
            json: false
          }
        end

        it_behaves_like "no flag is produced"
      end

      context "when the options associate :json with true" do
        let :options do
          {
            json: true
          }
        end

        it_behaves_like "a flag is produced", flag: "-json"
      end

      context "when the options associate :out with an object" do
        let :options do
          {
            out: "object"
          }
        end

        it_behaves_like "a flag is produced", flag: "-out=object"
      end

      context "when the options associate :parallelism with an object" do
        let :options do
          {
            parallelism: "object"
          }
        end

        it_behaves_like "a flag is produced", flag: "-parallelism=object"
      end

      context "when the options associate :state with an object" do
        let :options do
          {
            state: "object"
          }
        end

        it_behaves_like "a flag is produced", flag: "-state=object"
      end

      context "when the options associate :state_out with an object" do
        let :options do
          {
            state_out: "object"
          }
        end

        it_behaves_like "a flag is produced", flag: "-state-out=object"
      end

      context "when the options associate :update with false" do
        let :options do
          {
            update: false
          }
        end

        it_behaves_like "no flag is produced"
      end

      context "when the options associate :update with true" do
        let :options do
          {
            update: true
          }
        end

        it_behaves_like "a flag is produced", flag: "-update"
      end

      context "when the options associate :var with a hash of objects" do
        let :options do
          {
            var: {
              var_1_name: "var_1_value",
              var_2_name: "var 2 value"
            }
          }
        end

        it_behaves_like "a flag is produced", flag: "-var='var_1_name=var_1_value'"

        it_behaves_like "a flag is produced", flag: "-var='var_2_name=var 2 value'"
      end

      context "when the options associate :var_file with a array of objects" do
        let :options do
          {
            var_file: [
              "var_file_1",
              "var_file_2"
            ]
          }
        end

        it_behaves_like "a flag is produced", flag: "-var-file=var_file_1"

        it_behaves_like "a flag is produced", flag: "-var-file=var_file_2"
      end
    end
  end
end
