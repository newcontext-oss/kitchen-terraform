# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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

require "inspec"
require "kitchen/verifier/terraform"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/groups_examples"
require "support/kitchen/terraform/configurable_examples"
require "support/kitchen/driver/terraform_context"
require "support/kitchen/instance_context"

::RSpec.describe ::Kitchen::Verifier::Terraform do
  include_context "Kitchen::Instance initialized"

  let :described_instance do
    verifier
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Groups"

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#call(state)" do
    let :group do
      {
        attributes: {},
        controls: [
          "control"
        ],
        name: "name",
        port: 1234,
        ssh_key: "ssh_key",
        username: "username"
      }
    end

    before do
      default_config.merge!(
        groups: [
          group
        ],
        test_base_path: "/test/base/path"
      )

      instance
    end

    shared_context "Kitchen::Verifier::Inspec" do |exit_code:|
      include_context(
        "Kitchen::Driver::Terraform#output success",
        output: ::JSON.generate("output_name" => {"value" => "output_name value"})
      )

      let :runner do
        instance_double ::Inspec::Runner
      end

      let :runner_class do
        class_double(::Inspec::Runner).as_stubbed_const
      end

      before do
        allow(runner_class).to receive(:new).with(
          including(
            attributes: {
              "output_name" => "output_name value",
              "terraform_state" => "/kitchen/root/.kitchen/kitchen-terraform/suite-platform/terraform.tfstate"
            },
            "backend" => "local",
            controls: [
              "control"
            ],
            "host" => "localhost",
            "key_files" => ["ssh_key"],
            "port" => 1234,
            "user" => "username"
          )
        ).and_return runner

        allow(runner).to receive(:run).with(no_args).and_return exit_code
      end
    end

    subject do
      lambda do
        described_instance.call ::Hash.new
      end
    end

    context "when the result of enumerating group hosts is a failure" do
      include_context "Kitchen::Driver::Terraform#output failure"

      before do
        group.store :hostnames,
                    "hostnames"
      end

      it "raise an action failed error" do
        is_expected.to raise_error ::Kitchen::ActionFailed,
                                   /terraform output/
      end
    end

    context "when the InSpec runner returns an exit code of 0" do
      include_context "Kitchen::Verifier::Inspec",
                      exit_code: 0

      it "does not raise an error" do
        is_expected.to_not raise_error
      end
    end

    context "when the InSpec runner returns an exit code other than 0" do
      include_context "Kitchen::Verifier::Inspec",
                      exit_code: 1

      it "does raise an error" do
        is_expected.to raise_error ::Kitchen::ActionFailed,
                                   "Inspec Runner returns 1"
      end
    end
  end
end
