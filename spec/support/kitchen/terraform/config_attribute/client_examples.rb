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

require "kitchen/terraform/config_predicates/pathname_of_executable_file"
require "pathname"

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Client" do
  let :attribute do
    :client
  end

  context "when the config omits :client" do
    subject do
      described_class.new kitchen_root: "kitchen_root"
    end

    let :value do
      "terraform"
    end

    before do
      allow(::Kitchen::Terraform::ConfigPredicates::PathnameOfExecutableFile).to receive(:executable_pathname?).with(
        value: value,
      ).and_return true
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
    end

    specify "should associate :client with 'terraform'" do
      expect(subject[attribute]).to eq value
    end
  end

  context "when the config associates :client with an invalid pathname" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => 123
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /client.*must be a valid pathname of an executable file/
    end
  end

  context "when the config associates :client with the pathname of a nonexecutable file" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => value
    end

    let :pathname do
      instance_double ::Pathname
    end

    let :value do
      "./nonexecutable"
    end

    before do
      allow(::Kitchen::Terraform::ConfigPredicates::PathnameOfExecutableFile).to receive(:Pathname).with(
        value
      ).and_return pathname
      allow(pathname).to receive(:executable?).and_return false
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /client.*must be a valid pathname of an executable file/
    end
  end

  context "when the config associates :client with the pathname of an executable file" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => value
    end

    let :pathname do
      instance_double ::Pathname
    end

    let :value do
      "./executable"
    end

    before do
      allow(Kitchen::Terraform::ConfigPredicates::PathnameOfExecutableFile).to receive(:Pathname).with(
        value
      ).and_return pathname
      allow(pathname).to receive(:executable?).and_return true
    end

    specify "should not raise an error" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to_not raise_error
    end
  end
end
