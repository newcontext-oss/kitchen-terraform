# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "support/kitchen/terraform/config_attribute_contract/string_examples"
require "os"
require "tempfile"

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Client" do
  subject do
    described_class.new attribute => value, kitchen_root: "/kitchen-root"
  end

  let :attribute do
    :client
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttributeContract::String", attribute: :client, default_value: "terraform"

  describe "pathname expansion" do
    let :value do
      "abc"
    end

    context "when the config associates :client with a pathname which is not on the PATH" do
      specify "should expand the pathname" do
        allow(::TTY::Which).to receive(:exist?).with(value).and_return false

        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
        subject.send :expand_paths!
        path = subject[attribute]
        # On Windows this path will have a drive letter, so remove that
        path = path.gsub(/^[A-Za-z]:/, "") if OS.windows?

        expect(path).to eq "/kitchen-root/abc"
      end
    end

    context "when the config associates :client with a pathname which is on the PATH" do
      specify "should not expand the pathname" do
        allow(::TTY::Which).to receive(:exist?).with(value).and_return true

        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
        subject.send :expand_paths!

        expect(subject[attribute]).to eq value
      end
    end
  end

  describe "#doctor_config_client" do
    context "when the configured client does not exist" do
      let :value do
        "/nonexistent/pathname"
      end

      specify "should return true" do
        expect(subject.doctor_config_client).to be_truthy
      end
    end

    context "when the configured client is not executable" do
      let :value do
        ::Tempfile.new "client"
      end

      specify "should return true" do
        expect(subject.doctor_config_client).to be_truthy
      end

      after do
        value.close
        value.unlink
      end
    end

    context "when the configured client does exist and is executable" do
      let :value do
        file = ::Tempfile.new "client"
        file.chmod 0777

        file
      end

      specify "should return false" do
        expect(subject.doctor_config_client).to be_falsey
      end
    end
  end
end
