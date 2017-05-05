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

require "kitchen/terraform/client"
require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "support/kitchen/verifier/terraform/configure_inspec_runner_attributes_context"

::RSpec.describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes do
  describe ".call" do
    include_context "::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes.call"

    let :client do instance_double ::Kitchen::Terraform::Client end

    let :config do {} end

    let :group do {attributes: {}} end

    before do described_class.call client: client, config: config, group: group, terraform_state: "terraform_state" end

    subject do config.fetch :attributes end

    describe "defining default static attributes" do
      it "associates 'terraform_state' to the Terraform state path" do
        is_expected.to include "terraform_state" => "terraform_state"
      end
    end

    describe "defining default dynamic attributes" do
      it "associates each Terraform output name and value" do
        is_expected.to include "output_name_one" => "output_value_one", "output_name_two" => "output_value_two"
      end
    end

    describe "defining configured attributes" do
      let :group do {attributes: {"output_name_one" => "output_name_two"}} end

      it "associates each configured attribute name with the resolved value of the configured Terraform output name" do
        is_expected.to include "output_name_one" => "output_value_two"
      end
    end
  end
end
