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

require "kitchen/terraform/config_attribute_contract/array_of_strings"

::RSpec.describe ::Kitchen::Terraform::ConfigAttributeContract::ArrayOfStrings do
  describe "#call" do
    specify "should fail for a value that is not an array" do
      expect(subject.call(value: 123).errors.to_h).to include value: ["must be an array"]
    end

    specify "should pass for a value that an empty array" do
      expect(subject.call(value: []).errors.to_h).to be_empty
    end

    specify "should fail for a value that is an array with non-string elements" do
      expect(subject.call(value: [123]).errors.to_h.fetch(:value)).to include 0 => ["must be a string"]
    end

    specify "should pass for a value that is an array of strings" do
      expect(subject.call(value: ["abc"]).errors.to_h).to be_empty
    end
  end
end
