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

require "kitchen/driver/terraform/create_directories"
require "support/kitchen/driver/terraform/create_directories_context"

::RSpec.describe ::Kitchen::Driver::Terraform::CreateDirectories do
  describe ".call" do
    let :result do
      described_class.call directories: [
                             "directory_1",
                             "directory_2"
                           ]
    end

    context "when the directory creation experiences an error" do
      include_context "Kitchen::Driver::Terraform::CreateDirectories"

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
          is_expected.to match /error/
        end
      end
    end

    context "when the creation is a success" do
      include_context "Kitchen::Driver::Terraform::CreateDirectories",
                      failure: false

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

        it "describes the created directories" do
          is_expected.to eq "Created directories [\"directory_1\", \"directory_2\"]"
        end
      end
    end
  end
end
