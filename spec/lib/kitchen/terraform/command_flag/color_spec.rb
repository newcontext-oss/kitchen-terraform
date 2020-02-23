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

require "kitchen/terraform/command_flag/color"

::RSpec.describe ::Kitchen::Terraform::CommandFlag::Color do
  subject do
    described_class.new enabled: enabled
  end

  describe "#to_s" do
    context "when color is enabled" do
      let :enabled do
        true
      end

      specify "should return an empty string" do
        expect(subject.to_s).to eq ""
      end
    end

    context "when color is disabled" do
      let :enabled do
        false
      end

      specify "should return -no-color" do
        expect(subject.to_s).to eq "-no-color"
      end
    end
  end
end
