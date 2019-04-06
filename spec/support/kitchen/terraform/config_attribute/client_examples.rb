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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Client" do
  let :attribute do
    :client
  end

  context "when the config omits :client" do
    subject do
      described_class.new
    end

    before do
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
    end

    specify "should associate :client with terraform" do
      expect(subject[attribute]).to eq "terraform"
    end
  end

  context "when the config associates :client with a nonstring" do
    subject do
      described_class.new attribute => 123
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /client.*must be a string/
    end
  end

  context "when the config associates :client with an empty string" do
    subject do
      described_class.new attribute => ""
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /client.*must be filled/
    end
  end

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
