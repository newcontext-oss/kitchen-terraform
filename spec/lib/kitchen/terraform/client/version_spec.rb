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

require "kitchen/terraform/client/execute_command"
require "kitchen/terraform/client/version"

::RSpec.describe ::Kitchen::Terraform::Client::Version do
  describe ".call" do
    context "when the string thrown with :success does not match the expected format" do
      before do
        allow(::Kitchen::Terraform::Client::ExecuteCommand)
          .to receive(:call).with command: "version", config: "config", logger: "logger" do
            throw :success, "This is unexpected output"
          end
      end

      subject do
        catch :failure do
          described_class.call config: "config", logger: "logger"
        end
      end

      it "throws :failure with a string describing the failure" do
        is_expected.to eq "Terraform client version output did not contain a string matching 'vX.Y'"
      end
    end

    context "when the string thrown with :success does match the expected format" do
      before do
        allow(::Kitchen::Terraform::Client::ExecuteCommand)
          .to receive(:call).with command: "version", config: "config", logger: "logger" do
            throw :success, "Terraform v0.9.3\n\nYour version of Terraform is out of date! The latest version is " \
                              "0.9.4. You can update by downloading from www.terraform.io"
          end
      end

      subject do
        catch :success do
          described_class.call config: "config", logger: "logger"
        end
      end

      it "throws :success with a float representing the version" do
        is_expected.to eq 0.9
      end
    end
  end
end
