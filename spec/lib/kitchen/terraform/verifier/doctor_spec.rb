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
require "kitchen/terraform/system"
require "kitchen/terraform/verifier/doctor"
require "support/kitchen/logger_context"
require "tempfile"

::RSpec.describe ::Kitchen::Terraform::Verifier::Doctor do
  subject do
    described_class.new instance_name: "test-instance", logger: logger
  end

  include_context "Kitchen::Logger"

  describe "#call" do
    context "when the configured systems are empty" do
      let :config do
        {
          systems: [],
        }
      end

      specify "should return true" do
        expect(subject.call(config: config)).to be_truthy
      end
    end

    context "when the configured systems are not empty" do
      let :config do
        {
          systems: [
            ::Kitchen::Terraform::System.new(configuration_attributes: {}, logger: logger),
          ],
        }
      end

      specify "should return false" do
        expect(subject.call(config: config)).to be_falsey
      end
    end
  end
end
