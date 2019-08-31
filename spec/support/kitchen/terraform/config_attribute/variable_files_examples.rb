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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::VariableFiles" do
  let :attribute do
    :variable_files
  end

  context "when the config omits :variable_files" do
    subject do
      described_class.new
    end

    before do
      described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
    end

    specify "should associate :variables_files with an empty array" do
      expect(subject[attribute]).to eq []
    end
  end

  context "when the config associates :variable_files with a nonarray" do
    subject do
      described_class.new attribute => "abc"
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /variable_files.*must be an array/
    end
  end

  context "when the config associates :variable_files with an empty array" do
    subject do
      described_class.new attribute => []
    end

    specify "should not raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.not_to raise_error
    end
  end

  context "when the config associates :variable_files with an array which includes a nonstring" do
    subject do
      described_class.new attribute => [123]
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /variable_files.*0.*must be a string/
    end
  end

  context "when the config associates :variable_files with an array which includes an empty string" do
    subject do
      described_class.new attribute => [""]
    end

    specify "should raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.to raise_error ::Kitchen::UserError, /variable_files.*0.*must be filled/
    end
  end

  context "when the config associates :variable_files with an array which includes a nonempty string" do
    subject do
      described_class.new attribute => ["abc"]
    end

    specify "should not raise a Kitchen::UserError" do
      expect do
        described_class.validations.fetch(attribute).call attribute, subject[attribute], subject
      end.not_to raise_error
    end
  end
end
