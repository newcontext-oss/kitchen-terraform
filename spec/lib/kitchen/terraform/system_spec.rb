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
require "kitchen/terraform/inspec_factory"
require "kitchen/terraform/inspec_options_factory"
require "kitchen/terraform/inspec/fail_fast_with_hosts"
require "kitchen/terraform/system"
require "support/kitchen/logger_context"

::RSpec.describe ::Kitchen::Terraform::System do
  subject do
    described_class.new configuration_attributes: configuration_attributes, logger: ::Kitchen.logger
  end

  include_context "Kitchen::Logger"

  let :configuration_attributes do
    {
      bastion_host: "static-host",
      bastion_host_output: "",
      hosts_output: "hosts_output",
      name: "test",
      profile_locations: profile_locations,
    }
  end

  let :profile_locations do
    ["./profile"]
  end

  describe "#verify" do
    let :fail_fast_with_hosts do
      instance_double ::Kitchen::Terraform::InSpec::FailFastWithHosts
    end

    let :inspec_factory do
      instance_double ::Kitchen::Terraform::InSpecFactory
    end

    let :outputs do
      { hosts_output: { value: "dynamic-host" }, test_output: { value: "value" } }
    end

    let :variables do
      { test_variable: "value" }
    end

    before do
      allow(::Kitchen::Terraform::InSpecFactory).to receive(:new).with(
        fail_fast: true,
        hosts: ["dynamic-host"],
      ).and_return inspec_factory
      allow(inspec_factory).to receive(:build).with(
        options: {
          "distinct_exit" => false,
          ::Kitchen::Terraform::InSpecOptionsFactory.inputs_key => {
            "hosts_output" => "dynamic-host",
            "input_test_variable" => "value",
            "output_hosts_output" => "dynamic-host",
            "output_test_output" => "value",
            "test_output" => "value",
          },
          bastion_host: "static-host",
        },
        profile_locations: profile_locations,
      ).and_return fail_fast_with_hosts
    end

    context "when resolving the system fails" do
      let :outputs do
        { hosts_output: { count: "dynamic-host" }, test_output: { value: "value" } }
      end

      specify "should raise a client error" do
        expect do
          subject.verify fail_fast: true, outputs: outputs, variables: variables
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when verifying the system fails" do
      before do
        allow(fail_fast_with_hosts).to receive(:exec).and_raise ::Kitchen::TransientFailure, "Mocked InSpec error."
      end

      specify "should raise a transient failure error" do
        expect do
          subject.verify fail_fast: true, outputs: outputs, variables: variables
        end.to raise_error(
          ::Kitchen::TransientFailure,
          "Verifying the 'test' system failed:\n\tMocked InSpec error."
        )
      end
    end

    context "when verifying the system succeeds" do
      before do
        allow(fail_fast_with_hosts).to receive :exec
      end

      specify "should not raise an error" do
        expect do
          subject.verify fail_fast: true, outputs: outputs, variables: variables
        end.not_to raise_error
      end
    end
  end
end
