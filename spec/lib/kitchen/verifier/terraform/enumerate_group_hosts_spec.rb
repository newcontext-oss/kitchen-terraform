# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "kitchen/verifier/terraform/enumerate_group_hosts"

::RSpec.describe ::Kitchen::Verifier::Terraform::EnumerateGroupHosts do
  describe ".call" do
    let :client do instance_double ::Terraform::Client end

    let :group do {} end

    subject do lambda do |block| described_class.call client: client, group: group, &block end end

    context "when the group omits :hostnames" do
      it "yields 'localhost'" do is_expected.to yield_with_args host: "localhost" end
    end

    context "when the group associates :hostnames with an object" do
      let :hostnames do instance_double ::Object end

      before do
        group.store :hostnames, hostnames

        allow(client).to receive(:output_search).with(name: hostnames).and_return ["hostname"]
      end

      it "yields each resolved hostname" do is_expected.to yield_with_args host: "hostname" end
    end
  end
end
