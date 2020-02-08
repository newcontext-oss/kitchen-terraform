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

require "kitchen"
require "kitchen/terraform/verify_version_rescue_strategy/strict"

::RSpec.describe ::Kitchen::Terraform::VerifyVersionRescueStrategy::Strict do
  subject do
    described_class.new logger: logger
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  describe "#call" do
    describe "logging" do
      specify "should alert the user that the Terraform client version is unsupported" do
        expect(logger).to receive :error
      end

      after do
        begin
          subject.call
        rescue ::Kitchen::ActionFailed
        end
      end
    end

    describe "error handling" do
      specify "should raise an error because the action failed" do
        expect do
          subject.call
        end.to raise_error ::Kitchen::ActionFailed
      end
    end
  end
end
