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
require "kitchen/terraform/driver/doctor"
require "support/kitchen/logger_context"
require "tempfile"

::RSpec.describe ::Kitchen::Terraform::Driver::Doctor do
  subject do
    described_class.new instance_name: "test-instance", logger: logger
  end

  include_context "Kitchen::Logger"

  describe "#call" do
    context "when the deprecated configured client does not exist" do
      let :config do
        {
          client: "/nonexistent/pathname",
        }
      end

      let :deprecated_config do
        {
          client: "deprecated",
        }
      end

      specify "should return true" do
        expect(subject.call(config: config, deprecated_config: deprecated_config)).to be_truthy
      end
    end

    context "when the deprecated configured client is not executable" do
      let :client do
        ::Tempfile.new "client"
      end

      let :config do
        {
          client: client,
        }
      end

      let :deprecated_config do
        {
          client: "deprecated",
        }
      end

      specify "should return true" do
        expect(subject.call(config: config, deprecated_config: deprecated_config)).to be_truthy
      end

      after do
        client.close
        client.unlink
      end
    end

    context "when there are no errors" do
      let :config do
        {}
      end

      let :deprecated_config do
        {}
      end

      specify "should return false" do
        expect(subject.call(config: config, deprecated_config: deprecated_config)).to be_falsey
      end
    end
  end
end
