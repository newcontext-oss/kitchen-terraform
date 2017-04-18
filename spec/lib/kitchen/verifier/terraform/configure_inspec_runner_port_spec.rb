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

require "kitchen/verifier/terraform/configure_inspec_runner_port"

::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort do
  let :options do {"port" => options_port} end

  let :options_port do instance_double ::Object end

  before do described_class.call group: group, options: options end

  subject do options.fetch "port" end

  context "when the group associates :port with an object" do
    let :group do {port: group_port} end

    let :group_port do instance_double ::Object end

    it "associates the options' 'port' with the group's :port" do is_expected.to be group_port end
  end

  context "when the group omits :port" do
    let :group do {} end

    it "does not change the options' 'port'" do is_expected.to be options_port end
  end
end
