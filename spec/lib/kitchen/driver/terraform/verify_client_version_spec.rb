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

require "kitchen/driver/terraform/verify_client_version"

::RSpec.describe ::Kitchen::Driver::Terraform::VerifyClientVersion do
  describe ".call" do
    shared_examples "the version is deprecated" do |version:|
      let :result do
        described_class.call version: version
      end

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

        it "describes version #{version} as deprecated" do
          is_expected.to eq "Terraform version #{version} is deprecated and will not be supported by " \
                              "kitchen-terraform version 2.0; upgrade to Terraform version 0.9 to remain supported"
        end
      end
    end

    shared_examples "the version is unsupported" do |version:|
      let :result do
        described_class.call version: version
      end

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

        it "describes version #{version} as unsupported" do
          is_expected
            .to eq "Terraform version #{version} is not supported; supported Terraform versions are 0.7 through 0.9"
        end
      end
    end

    shared_examples "the version is supported" do |version:|
      let :result do
        described_class.call version: version
      end

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

        it "describes version #{version} as supported" do
          is_expected
            .to eq "Terraform version #{version} is supported"
        end
      end
    end

    context "when the version is 0.10" do
      it_behaves_like "the version is unsupported",
                      version: 0.10
    end

    context "when the version is 0.9" do
      it_behaves_like "the version is supported",
                      version: 0.9
    end

    context "when the version is 0.8" do
      it_behaves_like "the version is deprecated",
                      version: 0.8
    end

    context "when the version is 0.7" do
      it_behaves_like "the version is deprecated",
                      version: 0.7
    end

    context "when the version is 0.6" do
      it_behaves_like "the version is unsupported",
                      version: 0.6
    end
  end
end
