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

require "kitchen/terraform/system_and_hosts_enumerator"

::RSpec.describe ::Kitchen::Terraform::SystemAndHostsEnumerator do
  describe "#each_system_and_hosts" do
    context "when a system omits :hosts_output" do
      subject do
        described_class.new systems: [system], outputs: {}
      end

      let :system do
        {name: "name"}
      end

      specify "should yield the system and an empty string as the host" do
        expect do |block|
          subject.each_system_and_hosts &block
        end.to yield_with_args system: system, host: ""
      end
    end

    context "when a system associates :hosts_output with an invalid Terraform output name" do
      subject do
        described_class.new systems: [{hosts_output: "invalid"}], outputs: {"hosts" => {"value" => "host"}}
      end

      specify "should result in failure with a message" do
        expect do
          subject.each_system_and_hosts
        end.to result_in_failure.with_message "Enumeration of systems and hosts resulted in failure due to " \
                                              "the omission of the configured :hosts_output output or an " \
                                              "unexpected output structure: key not found: \"invalid\""
      end
    end

    context "when the system associates :hosts_output with a valid Terraform output name" do
      subject do
        described_class.new systems: [system], outputs: {"hosts" => {"value" => "host"}}
      end

      let :system do
        {hosts_output: "hosts"}
      end

      specify "should yield the system and each host from the output value" do
        expect do |block|
          subject.each_system_and_hosts &block
        end.to yield_with_args system: system, host: "host"
      end
    end
  end
end
