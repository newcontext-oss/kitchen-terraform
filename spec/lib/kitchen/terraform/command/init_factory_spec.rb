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

require "kitchen/terraform/command/init_factory"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::Command::InitFactory do
  subject do
    described_class.new version: version
  end

  describe "#build" do
    context "when the version is less than 0.15.0" do
      let :config do
        {
          backend_configurations: {},
          color: false,
          lock: true,
          lock_timeout: 123,
          plugin_directory: "/plugins",
          upgrade_during_init: true,
        }
      end

      let :version do
        ::Gem::Version.new "0.11.4"
      end

      specify "should return a pre 0.15.0 init command" do
        expect(subject.build(config: config)).to be_kind_of(
          ::Kitchen::Terraform::Command::Init::PreZeroFifteenZero
        )
      end
    end

    context "when the version is greater than or equal to 0.15.0" do
      let :config do
        {
          backend_configurations: {},
          color: false,
          plugin_directory: "/plugins",
          upgrade_during_init: true,
        }
      end

      let :version do
        ::Gem::Version.new "0.15.1"
      end

      specify "should return a post 0.15.0 init command" do
        expect(subject.build(config: config)).to be_kind_of(
          ::Kitchen::Terraform::Command::Init::PostZeroFifteenZero
        )
      end
    end
  end
end
