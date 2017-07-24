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

require "kitchen/terraform/client/options/state_out"

::RSpec.describe ::Kitchen::Terraform::Client::Options::StateOut do
  let :described_instance do
    described_class.new value: value
  end

  describe "#to_s" do
    subject do
      described_instance.to_s
    end

    let :value do
      123
    end

    it "returns '-state-out=<string representation of its value>'" do
      is_expected.to eq "-state-out=123"
    end
  end
end
