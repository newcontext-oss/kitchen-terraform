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

require "kitchen/terraform/inspec_factory"
require "kitchen/terraform/inspec/fail_fast_with_hosts"
require "kitchen/terraform/inspec/fail_slow_with_hosts"
require "kitchen/terraform/inspec/without_hosts"

::RSpec.describe ::Kitchen::Terraform::InSpecFactory do
  subject do
    described_class.new fail_fast: fail_fast, hosts: hosts
  end

  let :fail_fast do
    true
  end

  let :hosts do
    ["host"]
  end

  describe "#build" do
    let :options do
      {}
    end

    let :profile_locations do
      []
    end

    context "when there are no hosts" do
      let :hosts do
        []
      end

      specify "should return a without hosts strategy" do
        expect(subject.build(options: options, profile_locations: profile_locations)).to be_kind_of(
          ::Kitchen::Terraform::InSpec::WithoutHosts
        )
      end
    end

    context "when there are hosts and fail fast is true" do
      specify "should return a fail fast with hosts strategy" do
        expect(subject.build(options: options, profile_locations: profile_locations)).to be_kind_of(
          ::Kitchen::Terraform::InSpec::FailFastWithHosts
        )
      end
    end

    context "when there are hosts and fail fast is false" do
      let :fail_fast do
        false
      end

      specify "should return a fail slow with hosts strategy" do
        expect(subject.build(options: options, profile_locations: profile_locations)).to be_kind_of(
          ::Kitchen::Terraform::InSpec::FailSlowWithHosts
        )
      end
    end
  end
end
