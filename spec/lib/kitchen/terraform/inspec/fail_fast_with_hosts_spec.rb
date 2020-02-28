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

require "kitchen/terraform/inspec/fail_fast_with_hosts"
require "kitchen/terraform/inspec_runner"

::RSpec.describe ::Kitchen::Terraform::InSpec::FailFastWithHosts do
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
    []
  end

  describe "#exec" do
    let :inspec_runner_one do
      instance_double ::Kitchen::Terraform::InSpecRunner
    end

    let :inspec_runner_two do
      instance_double ::Kitchen::Terraform::InSpecRunner
    end

    before do
      allow(::Kitchen::Terraform::InSpecRunner).to receive(:new).with(
        options: { host: "host-one", key: "value" },
        profile_locations: profile_locations,
      ).and_return inspec_runner_one
      allow(::Kitchen::Terraform::InSpecRunner).to receive(:new).with(
        options: { host: "host-two", key: "value" },
        profile_locations: profile_locations,
      ).and_return inspec_runner_two
    end

    specify "should run InSpec against each host" do
      expect(inspec_runner_one).to receive :exec
      expect(inspec_runner_two).to receive :exec
    end

    after do
      subject.exec
    end
  end
end
