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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttributeType::HashOfSymbolsAndStrings" do |attribute:|
  context "when the config omits #{attribute.inspect}" do
    subject do
      described_class.new kitchen_root: "kitchen_root"
    end

    before do
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
    end

    specify "should associate #{attribute.inspect} with an empty hash" do
      expect(subject[attribute]).to eq({})
    end
  end

  context "when the config associates #{attribute.inspect} with a nonhash" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => []
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error(
        ::Kitchen::UserError,
        /#{attribute}.*must be a hash which includes only symbol keys and string values/
      )
    end
  end

  context "when the config associates #{attribute.inspect} with a an empty hash" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => {}
    end

    specify "should not raise an error" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.not_to raise_error
    end
  end

  context "when the config associates #{attribute.inspect} with a hash which has nonsymbol keys" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => { "key" => "value" }
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error(
        ::Kitchen::UserError,
        /#{attribute}.*must be a hash which includes only symbol keys and string values/
      )
    end
  end

  context "when the config associates #{attribute.inspect} with a hash which has nonstring values" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => { key: :value }
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error(
        ::Kitchen::UserError,
        /#{attribute}.*must be a hash which includes only symbol keys and string values/
      )
    end
  end

  context "when the config associates #{attribute.inspect} with a hash which has symobl keys and string values" do
    subject do
      described_class.new kitchen_root: "kitchen_root", attribute => { key: "value" }
    end

    specify "should not raise an error" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.not_to raise_error
    end
  end
end
