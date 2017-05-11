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

require "kitchen/terraform/verify_directory"

::RSpec.describe ::Kitchen::Terraform::VerifyDirectory do
  describe ".call" do
    context "when the verification is a failure" do
      before do
        allow(::FileUtils).to receive(:makedirs).with("/directory").and_raise ::SystemCallError, "system call error"
      end

      subject do
        catch :failure do
          described_class.call directory: "/directory"
        end
      end

      it "throws :failure with a string describing the failure" do
        is_expected.to eq "unknown error - system call error"
      end
    end

    context "when the verification is a success" do
      before do
        allow(::FileUtils).to receive(:makedirs).with "/directory"
      end

      subject do
        catch :success do
          described_class.call directory: "/directory"
        end
      end

      it "throws :success with a string describing the success" do
        is_expected.to eq "Verified directory /directory"
      end
    end
  end
end

require "fileutils"
