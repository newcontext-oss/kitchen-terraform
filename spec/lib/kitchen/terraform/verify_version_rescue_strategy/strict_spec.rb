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

require "kitchen/terraform/unsupported_client_version_error"
require "kitchen/terraform/verify_version_rescue_strategy/strict"

::RSpec.describe ::Kitchen::Terraform::VerifyVersionRescueStrategy::Strict do
  subject do
    described_class.new
  end

  describe "#call" do
    specify "should raise an error because the action failed" do
      expect do
        subject.call
      end.to raise_error ::Kitchen::Terraform::UnsupportedClientVersionError
    end
  end
end
