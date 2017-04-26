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

require "terraform/no_output_parser"

::RSpec.describe ::Terraform::NoOutputParser do
  let :described_instance do described_class.new end

  describe "#each_name" do
    subject do lambda do |block| described_instance.each_name &block end end

    it "does not yield" do is_expected.to_not yield_control end
  end

  describe "#iterate_parsed_output" do
    subject do lambda do |block| described_instance.iterate_parsed_output &block end end

    it "does not yield" do is_expected.to_not yield_control end
  end

  describe "#parsed_output" do
    subject do described_instance.parsed_output end

    it "returns an empty string" do is_expected.to eq "" end
  end
end
