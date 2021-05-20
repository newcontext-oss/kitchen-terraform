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
require "kitchen/terraform/systems_verifier/fail_fast"

::RSpec.describe ::Kitchen::Terraform::SystemsVerifier::FailFast do
  subject do
    described_class.new systems: [system_one, system_two]
  end

  let :system_one do
    instance_double ::Kitchen::Terraform::System
  end

  let :system_two do
    instance_double ::Kitchen::Terraform::System
  end

  describe "#verify" do
    let :outputs do
      {}
    end

    let :variables do
      {}
    end

    context "when verifying the first system fails" do
      before do
        allow(system_one).to receive(:verify).with(fail_fast: true, outputs: outputs, variables: variables).and_raise(
          ::Kitchen::TransientFailure,
          "Mocked system one error."
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.verify outputs: outputs, variables: variables
        end.to raise_error ::Kitchen::TransientFailure, "Mocked system one error."
      end
    end

    context "when verifying the second system fails" do
      before do
        allow(system_one).to receive(:verify).with fail_fast: true, outputs: outputs, variables: variables
        allow(system_two).to receive(:verify).with(fail_fast: true, outputs: outputs, variables: variables).and_raise(
          ::Kitchen::TransientFailure,
          "Mocked system two error."
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.verify outputs: outputs, variables: variables
        end.to raise_error ::Kitchen::TransientFailure, "Mocked system two error."
      end
    end

    context "when verifying both systems succeeds" do
      before do
        allow(system_one).to receive(:verify).with fail_fast: true, outputs: outputs, variables: variables
        allow(system_two).to receive(:verify).with fail_fast: true, outputs: outputs, variables: variables
      end

      specify "should not raise an error" do
        expect do
          subject.verify outputs: outputs, variables: variables
        end.not_to raise_error
      end
    end
  end
end
