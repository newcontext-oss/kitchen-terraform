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

require "kitchen/terraform/config_attribute_contract/optional_string"

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttributeContract::OptionalString" do |attribute:, default_value:|
  context "when the config omits #{attribute.inspect}" do
    subject do
      described_class.new
    end

    before do
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
    end

    specify "should associate #{attribute.inspect} with #{default_value}" do
      expect(subject[attribute]).to be default_value
    end
  end

  context "when the config associates #{attribute.inspect} with a nonstring" do
    subject do
      described_class.new attribute => 123
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /#{attribute}.*must be a string/
    end
  end

  context "when the config associates #{attribute.inspect} with an empty string" do
    subject do
      described_class.new attribute => ""
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /#{attribute}.*must be filled/
    end
  end

  context "when the config associates #{attribute.inspect} with a nonempty string" do
    subject do
      described_class.new attribute => "abc"
    end

    specify "should not raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.not_to raise_error
    end
  end
end
