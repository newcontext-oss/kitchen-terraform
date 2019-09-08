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
require "kitchen/terraform/version_verifier_factory"
require "kitchen/terraform/version_verifier"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VersionVerifierFactory do
  subject do
    described_class.new strict: strict
  end

  describe "#build" do
    context "when strict is true" do
      let :strict do
        true
      end

      specify "the version is strictly verified" do
        expect(::Kitchen::Terraform::VersionVerifier).to receive :strict
      end
    end

    context "when strict is false" do
      let :strict do
        false
      end

      specify "the version is strictly verified" do
        expect(::Kitchen::Terraform::VersionVerifier).to receive :permissive
      end
    end

    after do
      subject.build logger: ::Kitchen::Logger.new, version_requirement: ::Gem::Requirement.new("0.0.0")
    end
  end
end
