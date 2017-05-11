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

require "kitchen"
require "kitchen/driver/terraform/verify_dependencies"
require "kitchen/terraform/client/version"
require "kitchen/terraform/verify_client_version"

::RSpec.shared_examples "::Kitchen::Driver::Terraform::VerifyDependencies" do
  before do
    allow(::Kitchen::Terraform::Client::Version)
      .to receive(:call).with(config: duck_type(:fetch), logger: duck_type(:<<)).and_throw :success, "version"

    allow(::Kitchen::Terraform::VerifyClientVersion)
      .to receive(:call).with(version: "version").and_throw :success, "verified version"

    allow(::Kitchen::Terraform::VerifyDirectory)
      .to receive(:call).with(directory: kind_of(::String)).and_throw :success, "verified directory"
  end

  subject do
    lambda do
      described_method.call
    end
  end

  shared_examples "the verification of dependencies is a failure" do
    it "raises a user error" do
      is_expected.to raise_error ::Kitchen::UserError, "failure"
    end
  end

  context "when the command to retrieve the Terraform client version is a failure" do
    before do
      allow(::Kitchen::Terraform::Client::Version)
        .to receive(:call).with(config: duck_type(:fetch), logger: duck_type(:<<)).and_throw :failure, "failure"
    end

    it_behaves_like "the verification of dependencies is a failure"
  end

  context "when the verification of the Terraform client version is a failure" do
    before do
      allow(::Kitchen::Terraform::VerifyClientVersion)
        .to receive(:call).with(version: "version").and_throw :failure, "failure"
    end

    it_behaves_like "the verification of dependencies is a failure"
  end

  context "when the verification of a directory is a failure" do
    before do
      allow(::Kitchen::Terraform::VerifyDirectory)
        .to receive(:call).with(directory: "/kitchen/root").and_throw :failure, "failure"
    end

    it_behaves_like "the verification of dependencies is a failure"
  end

  context "when the verification of dependencies is a success" do
    it "does not raise an error" do
      is_expected.to_not raise_error
    end
  end
end
