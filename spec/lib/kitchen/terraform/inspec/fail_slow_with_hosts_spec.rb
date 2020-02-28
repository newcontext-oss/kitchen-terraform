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
require "kitchen/terraform/inspec_runner"
require "kitchen/terraform/inspec/fail_slow_with_hosts"

::RSpec.describe ::Kitchen::Terraform::InSpec::FailSlowWithHosts do
  subject do
    described_class.new hosts: hosts, options: options, profile_locations: profile_locations
  end

  let :hosts do
    ["host-one", "host-two"]
  end

  let :options do
    { key: "value" }
  end

  let :profile_locations do
    ["./profile"]
  end

  describe "#exec" do
    let :runner_one do
      instance_double ::Kitchen::Terraform::InSpecRunner
    end

    let :runner_two do
      instance_double ::Kitchen::Terraform::InSpecRunner
    end

    before do
      allow(::Kitchen::Terraform::InSpecRunner).to receive(:new).with(
        options: { host: "host-one", key: "value" },
        profile_locations: profile_locations,
      ).and_return runner_one
      allow(::Kitchen::Terraform::InSpecRunner).to receive(:new).with(
        options: { host: "host-two", key: "value" },
        profile_locations: profile_locations,
      ).and_return runner_two
    end

    context "when running InSpec against both hosts fails" do
      before do
        allow(runner_one).to receive(:exec).and_raise(
          ::Kitchen::TransientFailure,
          "Running InSpec against the 'host-one' host failed."
        )
        allow(runner_two).to receive(:exec).and_raise(
          ::Kitchen::TransientFailure,
          "Running InSpec against the 'host-two' host failed."
        )
      end

      specify "should capture the errors for each host and raise them collectively as a transient failure error" do
        expect do
          subject.exec
        end.to raise_error(
          ::Kitchen::TransientFailure,
          "Running InSpec against the 'host-one' host failed.\n\nRunning InSpec against the 'host-two' host failed."
        )
      end
    end

    context "when running InSpec against one host fails" do
      before do
        allow(runner_one).to receive :exec
        allow(runner_two).to receive(:exec).and_raise(
          ::Kitchen::TransientFailure,
          "Running InSpec against the 'host-two' host failed."
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.exec
        end.to raise_error(
          ::Kitchen::TransientFailure,
          "Running InSpec against the 'host-two' host failed."
        )
      end
    end

    context "when running InSpec against both hosts succeeds" do
      before do
        allow(runner_one).to receive :exec
        allow(runner_two).to receive :exec
      end

      specify "should not raise an error" do
        expect do
          subject.exec
        end.not_to raise_error
      end
    end
  end
end
