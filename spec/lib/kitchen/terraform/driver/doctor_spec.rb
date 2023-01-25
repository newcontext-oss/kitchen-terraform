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
require "tempfile"

::RSpec.describe ::Kitchen::Terraform::Driver::Doctor do
  subject do
    described_class.new logger: logger
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  describe "#call" do
    context "when the configured client does not exist" do
      let :config do
        {
          client: "/nonexistent/pathname"
        }
      end

      specify "should return true" do
        expect(subject.call(config: config)).to be_truthy
      end
    end

    context "when the configured client is not executable" do
      let :config do
        {
          client: ::Tempfile.new("client")
        }
      end

      specify "should raise a user error" do
        expect(subject.call(config: config)).to be_truthy
      end

      after do
        config.fetch(:client).tap do |client|
          client.close
          client.unlink
        end
      end
    end
  end
end
