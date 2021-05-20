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

require "kitchen/terraform/systems_verifier_factory"
require "kitchen/terraform/systems_verifier/fail_fast"
require "kitchen/terraform/systems_verifier/fail_slow"

::RSpec.describe ::Kitchen::Terraform::SystemsVerifierFactory do
  subject do
    described_class.new fail_fast: fail_fast
  end

  let :fail_fast do
    true
  end

  describe "#build" do
    let :systems do
      []
    end

    context "when fail fast is true" do
      specify "should return a fail fast strategy" do
        expect(subject.build(systems: systems)).to be_kind_of ::Kitchen::Terraform::SystemsVerifier::FailFast
      end
    end

    context "when fail fast is false" do
      let :fail_fast do
        false
      end

      specify "should return a fail slow strategy" do
        expect(subject.build(systems: systems)).to be_kind_of ::Kitchen::Terraform::SystemsVerifier::FailSlow
      end
    end
  end
end
