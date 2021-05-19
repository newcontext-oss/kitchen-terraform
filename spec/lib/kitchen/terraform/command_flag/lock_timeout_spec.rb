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

require "kitchen/terraform/command_flag/lock_timeout"

::RSpec.describe ::Kitchen::Terraform::CommandFlag::LockTimeout do
  subject do
    described_class.new duration: duration
  end

  describe "#to_s" do
    let :duration do
      123
    end

    specify "should return -lock-timeout with the duration and a unit of seconds" do
      expect(subject.to_s).to eq "-lock-timeout=123s"
    end
  end
end
