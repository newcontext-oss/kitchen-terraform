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

require "terraform/command_options"

::RSpec.describe ::Terraform::CommandOptions do
  let :described_instance do described_class.new options: options end

  let :key_method do key.tr "-", "_" end

  let :options do ::Set.new end

  let :value do "value" end

  shared_examples "#fetch" do
    before do options.add ::Terraform::CommandOption.new key: key, value: value end

    subject do described_instance.send key_method end

    it "fetches the option" do is_expected.to eq value end
  end

  shared_examples "#store" do
    before do described_instance.send "#{key_method}=", value end

    subject do described_instance.to_s end

    it "sets the option" do is_expected.to include "-#{key}=#{value}" end
  end

  describe "#color=" do
    before do described_instance.color = value end

    subject do described_instance.to_s end

    context "when the value is true" do
      let :value do true end

      it "takes no action" do is_expected.to be_empty end
    end

    context "when the value is false" do
      let :value do false end

      it "sets -no-color" do is_expected.to include "-no-color" end
    end
  end

  describe "#destroy=" do it_behaves_like "#store" do let :key do "destroy" end end end

  describe "#input=" do it_behaves_like "#store" do let :key do "input" end end end

  describe "#json=" do it_behaves_like "#store" do let :key do "json" end end end

  describe "#out" do it_behaves_like "#fetch" do let :key do "out" end end end

  describe "#out=" do it_behaves_like "#store" do let :key do "out" end end end

  describe "#state" do it_behaves_like "#fetch" do let :key do "state" end end end

  describe "#state=" do it_behaves_like "#store" do let :key do "state" end end end

  describe "#state_out" do it_behaves_like "#fetch" do let :key do "state-out" end end end

  describe "#state_out=" do it_behaves_like "#store" do let :key do "state-out" end end end
end
