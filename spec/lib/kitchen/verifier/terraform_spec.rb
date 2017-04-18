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
require "support/kitchen/instance_context"
require "support/kitchen/verifier/terraform/configure_inspec_runner_attributes_context"
require "support/terraform/configurable_context"
require "support/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Verifier::Terraform do
  it_behaves_like ::Terraform::Configurable do
    include_context "instance"

    let :described_instance do verifier end
  end

  describe "#call(state)" do
    include_context "silent_client"

    include_context ::Kitchen::Instance

    include_context "::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes.call" do
      let :client do silent_client end
    end

    let :described_instance do verifier end

    let :group do {attributes: {}, controls: ["control"], name: "name", port: 1234, username: "username"} end

    let :host do instance_double ::Object end

    let :runner do instance_double ::Inspec::Runner end

    let :runner_class do class_double(::Inspec::Runner).as_stubbed_const end

    before do
      default_config.merge! groups: [group], test_base_path: "/test/base/path"

      allow(runner_class).to receive(:new).with(
        including(
          attributes: {
            "output_name_one" => "output_value_one", "output_name_two" => "output_value_two",
            "terraform_state" => "/kitchen/root/.kitchen/kitchen-terraform/suite-platform/terraform.tfstate"
          }, "backend" => "local", controls: ["control"], "host" => "localhost", "port" => 1234, "user" => "username"
        )
      ).and_return runner

      allow(runner).to receive(:run).with(no_args).and_return exit_code

      instance
    end

    subject do lambda do described_instance.call ::Hash.new end end

    context "when the InSpec runner returns an object equivalent to 0" do
      let :exit_code do 0 end

      it "does not raise an error" do is_expected.to_not raise_error end
    end

    context "when the InSpec runner returns an object not equivalent to 0" do
      let :exit_code do 1 end

      it "does raise an error" do is_expected.to raise_error ::Kitchen::ActionFailed end
    end
  end
end
