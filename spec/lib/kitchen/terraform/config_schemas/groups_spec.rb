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

require "kitchen/terraform/config_schemas/groups"

::RSpec.describe ::Kitchen::Terraform::ConfigSchemas::Groups do
  subject do
    described_class
  end

  describe ".call" do
    specify "the value must be an array" do
      expect(subject.call(value: 123).errors).to contain_exactly [:value, ["must be an array"]]
    end

    specify "the value may be an array which includes no elements" do
      expect(subject.call(value: []).errors).to be_empty
    end

    specify "the value may be an array which includes hashes" do
      expect(subject.call(value: [123]).errors).to contain_exactly [:value, {0 => ["must be a hash"]}]
    end
  end
end
