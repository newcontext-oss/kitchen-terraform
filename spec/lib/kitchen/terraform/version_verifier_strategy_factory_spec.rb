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
require "kitchen/terraform/version_verifier_strategy_factory"
require "kitchen/terraform/version_verifier_strategy/supported"
require "kitchen/terraform/version_verifier_strategy/unsupported"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VersionVerifierStrategyFactory do
  describe "#build" do
    subject do
      described_class.new version_requirement: ::Gem::Requirement.new("~> 1.2.3")
    end

    context "when the version is supported" do
      specify "should return a supported strategy" do
        expect(subject.build(version: ::Gem::Version.new("1.2.4"))).to be_kind_of(
          ::Kitchen::Terraform::VersionVerifierStrategy::Supported
        )
      end
    end

    context "when the version is unsupported" do
      specify "should return an unsupported strategy" do
        expect(subject.build(version: ::Gem::Version.new("1.2.2"))).to be_kind_of(
          ::Kitchen::Terraform::VersionVerifierStrategy::Unsupported
        )
      end
    end
  end
end
