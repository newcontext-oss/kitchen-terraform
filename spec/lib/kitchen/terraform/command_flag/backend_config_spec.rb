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

require "kitchen/terraform/command_flag/backend_config"

::RSpec.describe ::Kitchen::Terraform::CommandFlag::BackendConfig do
  subject do
    described_class.new arguments: arguments
  end

  describe "#to_s" do
    let :arguments do
      { key_one: "value one", key_two: "value two" }
    end

    specify "should return -backend-config for each argument" do
      expect(subject.to_s).to eq "-backend-config=\"key_one=value one\" -backend-config=\"key_two=value two\""
    end
  end
end
