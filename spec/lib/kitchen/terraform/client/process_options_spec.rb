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

::RSpec.describe ::Kitchen::Terraform::Client::ProcessOptions do
  describe ".call" do
    context "when an unsupported option is detected" do
      subject do
        catch :failure do
          described_class.call unprocessed_options: {
            unsupported_option: "unsupported_option"
          }
        end
      end

      it "throws :failure with a string describing the failure" do
        is_expected.to eq "'unsupported_option' is not supported as a ::Kitchen::Terraform::Client option"
      end
    end

    context "when all options are processed" do
      subject do
        catch :success do
          described_class.call unprocessed_options: options
        end
      end

      shared_examples "no flag is produced" do
        it "throws :success with an empty array" do
          is_expected.to be_empty
        end
      end

      context "when the options associate :color with false" do
        let :options do
          {
            color: false
          }
        end

        it "throws :success with an array including '-no-color'" do
          is_expected.to include "-no-color"
        end
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

        it "throws :success with an array including '-destroy'" do
          is_expected.to include "-destroy"
        end
      end

      context "when the options associate :input with an object" do
        let :options do
          {
            input: "object"
          }
        end

        it "throws :success with an array including '-input=object'" do
          is_expected.to include "-input=object"
        end
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

        it "throws :success with an array including '-json'" do
          is_expected.to include "-json"
        end
      end

      context "when the options associate :out with an object" do
        let :options do
          {
            out: "object"
          }
        end

        it "throws :success with an array including '-out=object'" do
          is_expected.to include "-out=object"
        end
      end

      context "when the options associate :parallelism with an object" do
        let :options do
          {
            parallelism: "object"
          }
        end

        it "throws :success with an array including '-parallelism=object'" do
          is_expected.to include "-parallelism=object"
        end
      end

      context "when the options associate :state with an object" do
        let :options do
          {
            state: "object"
          }
        end

        it "throws :success with an array including '-state=object'" do
          is_expected.to include "-state=object"
        end
      end

      context "when the options associate :state_out with an object" do
        let :options do
          {
            state_out: "object"
          }
        end

        it "throws :success with an array including '-state-out=object'" do
          is_expected.to include "-state-out=object"
        end
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

        it "throws :success with an array including '-json'" do
          is_expected.to include "-update"
        end
      end

      context "when the options associate :var with a hash of objects" do
        let :options do
          {
            var: {
              var_1_name: "var_1_value",
              var_2_name: "var_2_value"
            }
          }
        end

        it "throws :success with an array including '-var=\"var_1_name=var_1_value\"', " \
             "'-var=\"var_2_name=var_2_value\"'" do
          is_expected.to include "-var='var_1_name=var_1_value'",
                                 "-var='var_2_name=var_2_value'"
        end
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

        it "throws :success with an array including '-var-file=var_file_1', '-var-file=var_file_2'" do
          is_expected.to include "-var-file=var_file_1",
                                 "-var-file=var_file_2"
        end
      end
    end
  end
end
