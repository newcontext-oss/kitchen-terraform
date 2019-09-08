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
require "kitchen/terraform/version_verifier"
require "kitchen/terraform/version_verifier_strategy/permissive"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VersionVerifier do
  let :logger do
    ::Kitchen::Logger.new
  end

  let :requirement do
    ::Gem::Requirement.create ">= 0.1.2", "< 3.4.5"
  end

  describe ".permissive" do
    specify "should select the permissive strategy" do
      expect(::Kitchen::Terraform::VersionVerifierStrategy::Permissive).to receive :new
    end

    after do
      described_class.permissive logger: logger, requirement: requirement
    end
  end

  describe ".strict" do
    specify "should select the strict strategy" do
      expect(::Kitchen::Terraform::VersionVerifierStrategy::Strict).to receive :new
    end

    after do
      described_class.strict logger: logger, requirement: requirement
    end
  end

  describe "#verify" do
    subject do
      described_class.new logger: logger, requirement: requirement, strategy: strategy
    end

    let :strategy do
      double "Kitchen::Terraform::VersionVerifyStrategy"
    end

    context "when the version does not meet the requirement" do
      specify "should indicate to the strategy that the version is unsupported" do
        expect(strategy).to receive :unsupported
      end

      after do
        subject.verify version: ::Gem::Version.create("6.7.8")
      end
    end

    context "when the version does meet the requirement" do
      specify "should indicate to the strategy that the version is supported" do
        expect(strategy).to receive :supported
      end

      after do
        subject.verify version: ::Gem::Version.create("1.2.3")
      end
    end
  end
end
