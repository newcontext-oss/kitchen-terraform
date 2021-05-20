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
require "kitchen/terraform/system_bastion_host_resolver"

::RSpec.describe ::Kitchen::Terraform::SystemBastionHostResolver do
  subject do
    described_class.new outputs: outputs
  end

  let :outputs do
    { valid_output: { value: valid_output }, invalid_output: { count: "test" } }
  end

  let :valid_output do
    "dynamic-host"
  end

  describe "#resolve" do
    context "when the 'value' key is absent from the bastion host output" do
      specify "should raise a client error" do
        expect do
          subject.resolve bastion_host: "", bastion_host_output: :invalid_output
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the bastion host output key is absent from the outputs" do
      specify "should raise a client error" do
        expect do
          subject.resolve bastion_host: "", bastion_host_output: :missing_output
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the bastion host output key is present in the outputs" do
      specify "should yield the value" do
        expect do |block|
          subject.resolve bastion_host: "", bastion_host_output: :valid_output, &block
        end.to yield_with_args bastion_host: valid_output
      end
    end

    context "when both bastion_host and bastion_host_output are provided" do
      let :bastion_host do
        "static-host"
      end

      specify "should yield the value of bastion_host" do
        expect do |block|
          subject.resolve bastion_host: bastion_host, bastion_host_output: :valid_output, &block
        end.to yield_with_args bastion_host: bastion_host
      end
    end

    context "when neither bastion_host nor bastion_host_output are provided" do
      specify "should not yield" do
        expect do |block|
          subject.resolve bastion_host: "", bastion_host_output: "", &block
        end.not_to yield_control
      end
    end
  end
end
