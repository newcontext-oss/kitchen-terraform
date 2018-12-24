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

require "kitchen/terraform/command/version"
require "kitchen/terraform/verify_version"

::RSpec.describe ::Kitchen::Terraform::VerifyVersion do
  describe "#call" do
    shared_examples "the version is unsupported" do
      specify "should result in failure with a message which provides a remedy for the lack of support" do
        expect do
          described_class.call
        end.to result_in_failure.with_message "#{version} is not supported; install Terraform ~> v0.11.4"
      end
    end

    shared_examples "the version is supported" do
      specify "should result in success" do
        expect do
          subject.call
        end.not_to raise_error
      end
    end

    context "when the version is 0.11.3" do
      let :version do
        "Terraform v0.11.3"
      end

      before do
        allow(::Kitchen::Terraform::Command::Version).to receive(:run).and_yield(
          version: ::Kitchen::Terraform::Command::Version.new(version),
        )
      end

      it_behaves_like "the version is unsupported"
    end

    context "when the version is 0.11.4" do
      let :version do
        "Terraform v0.11.4"
      end

      before do
        allow(::Kitchen::Terraform::Command::Version).to receive(:run).and_yield(
          version: ::Kitchen::Terraform::Command::Version.new(version),
        )
      end

      it_behaves_like "the version is supported"
    end

    context "when the version is 0.12.0" do
      let :version do
        "Terraform v0.12.0"
      end

      before do
        allow(::Kitchen::Terraform::Command::Version).to receive(:run).and_yield(
          version: ::Kitchen::Terraform::Command::Version.new(version),
        )
      end

      it_behaves_like "the version is unsupported"
    end
  end
end
