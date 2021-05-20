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

require "kitchen"
require "kitchen/terraform/verify_version_rescue_strategy/permissive"

::RSpec.describe ::Kitchen::Terraform::VerifyVersionRescueStrategy::Permissive do
  subject do
    described_class.new logger: logger
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  describe "#call" do
    specify "should warn the user that the Terraform client version is unsupported" do
      expect(logger).to receive :warn
    end

    after do
      subject.call
    end
  end
end
