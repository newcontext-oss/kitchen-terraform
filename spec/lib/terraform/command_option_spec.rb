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

require "terraform/command_option"

::RSpec.describe ::Terraform::CommandOption do
  let :described_instance do described_class.new key: "key", value: value end

  let :equivalent_instance do described_class.new key: " key", value: "value " end

  let :unequivalent_instance do described_class.new key: "other_key", value: "other_value" end

  let :value do "value" end

  shared_examples "#==" do
    context "when the options do have equivalent tuples" do
      subject do described_instance == equivalent_instance end

      it "they are equivalent" do is_expected.to be_truthy end
    end

    context "when the options do not have equivalent tuples" do
      subject do described_instance == unequivalent_instance end

      it "they are not equivalent" do is_expected.to be_falsey end
    end
  end

  describe "#==" do it_behaves_like "#==" end

  describe "#eql?" do it_behaves_like "#==" end

  describe "#hash" do
    subject do described_instance.hash end

    it "is equivalent for equivalent instances" do is_expected.to eq equivalent_instance.hash end

    it "is not equivalent for unequivalent instances" do is_expected.to_not eq unequivalent_instance.hash end
  end

  describe "#to_s" do
    subject do described_instance.to_s end

    context "when the option does have a value" do
      it "returns the tuple formatted for the command line" do is_expected.to eq "-key=value" end
    end

    context "when the option does not have a value" do
      let :value do "" end

      it "returns the key formatted for the command line" do is_expected.to eq "-key" end
    end
  end

  describe "#tuple" do
    subject do described_instance.tuple end

    it "returns an array of the key and the value" do is_expected.to contain_exactly "key", "value" end
  end
end
