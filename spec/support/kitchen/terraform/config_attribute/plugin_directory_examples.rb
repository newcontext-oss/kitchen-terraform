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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::PluginDirectory" do
  let :attribute do
    :plugin_directory
  end

  context "when the config omits :plugin_directory" do
    subject do
      described_class.new
    end

    before do
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
    end

    specify "should associate :plugin_directory with nil" do
      expect(subject[attribute]).to be nil
    end
  end

  context "when the config associates :plugin_directory with a nonstring" do
    subject do
      described_class.new attribute => 123
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /plugin_directory.*must be a string/
    end
  end

  context "when the config associates :plugin_directory with an empty string" do
    subject do
      described_class.new attribute => ""
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /plugin_directory.*must be filled/
    end
  end

  context "when the config associates :plugin_directory with a nonempty string" do
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
