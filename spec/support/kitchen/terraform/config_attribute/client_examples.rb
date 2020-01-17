# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "support/kitchen/terraform/config_schemas/string_examples"

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Client" do
  let :attribute do
    :client
  end

  it_behaves_like "Kitchen::Terraform::ConfigSchemas::String", attribute: :client, default_value: "terraform"

  context "when the config associates :client with a pathname which is not on the PATH" do
    subject do
      described_class.new attribute => value, kitchen_root: "/kitchen-root"
    end

    let :value do
      "abc"
    end

    before do
      allow(::TTY::Which).to receive(:exist?).with(value).and_return false
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      subject.send :expand_paths!
    end

    specify "should expand the pathname" do
      expect(subject[attribute]).to eq "/kitchen-root/abc"
    end
  end

  context "when the config associates :client with a pathname which is on the PATH" do
    subject do
      described_class.new attribute => value, kitchen_root: "/kitchen-root"
    end

    let :value do
      "abc"
    end

    before do
      allow(::TTY::Which).to receive(:exist?).with(value).and_return true
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      subject.send :expand_paths!
    end

    specify "should not expand the pathname" do
      expect(subject[attribute]).to eq value
    end
  end
end
