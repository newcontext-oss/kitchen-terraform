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
require "kitchen/terraform/system_hosts_resolver"

::RSpec.describe ::Kitchen::Terraform::SystemHostsResolver do
  subject do
    described_class.new outputs: outputs
  end

  let :outputs do
    { valid_output: { value: "dynamic-host" }, invalid_output: { count: "test" } }
  end

  describe "#resolve" do
    context "when the 'value' key is absent from the hosts output" do
      specify "should raise a client error" do
        expect do
          subject.resolve hosts: [], hosts_output: :invalid_output
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the hosts output key is absent from the outputs" do
      specify "should raise a client error" do
        expect do
          subject.resolve hosts: [], hosts_output: :missing_output
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the hosts output key is present in the outputs" do
      let :hosts do
        ["static-host"]
      end

      before do
        subject.resolve hosts: hosts, hosts_output: :valid_output
      end

      specify "should append the value of the hosts output to the hosts" do
        expect(hosts).to contain_exactly "static-host", "dynamic-host"
      end
    end
  end
end
