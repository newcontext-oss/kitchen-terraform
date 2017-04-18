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

require "kitchen/verifier/terraform/configure_inspec_runner_user"

::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser do
  let :options do {"user" => options_user} end

  let :options_user do instance_double ::Object end

  before do described_class.call group: group, options: options end

  subject do options.fetch "user" end

  context "when the group associates :username with an object" do
    let :group do {username: group_username} end

    let :group_username do instance_double ::Object end

    it "associates the options' 'user' with the group's :username" do is_expected.to eq group_username end
  end

  context "when the group omits :username" do
    let :group do {} end

    it "does not change the options' 'user'" do is_expected.to eq options_user end
  end
end
