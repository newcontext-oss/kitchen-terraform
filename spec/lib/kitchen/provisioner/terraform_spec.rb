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

require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/provisioner/terraform"
require "kitchen/terraform/variables_manager"
require "kitchen/terraform/outputs_manager"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Provisioner::Terraform do
  subject do
    described_class.new config
  end

  let :config do
    {}
  end

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#call" do
    let :driver do
      ::Kitchen::Driver::Terraform.new({})
    end

    let :kitchen_instance do
      ::Kitchen::Instance.new(
        driver: driver,
        lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
        logger: kitchen_logger,
        platform: ::Kitchen::Platform.new(name: "test-platform"),
        provisioner: ::Kitchen::Provisioner::Base.new,
        state_file: ::Kitchen::StateFile.new("/kitchen", "test-suite-test-platform"),
        suite: ::Kitchen::Suite.new(name: "test-suite"),
        transport: ::Kitchen::Transport::Base.new,
        verifier: ::Kitchen::Verifier::Base.new,
      )
    end

    let :kitchen_logger do
      ::Kitchen::Logger.new
    end

    let :kitchen_instance_state do
      {}
    end

    before do
      allow(kitchen_instance).to receive(:driver).and_return driver
      allow(driver).to(receive(:retrieve_variables) do |&block|
        block.call variables: { "variable" => "input_value" }

        driver
      end)
      subject.finalize_config! kitchen_instance
    end

    describe "error handling" do
      context "when the driver create action is a failure" do
        before do
          allow(driver).to receive(:apply).and_raise ::Kitchen::ActionFailed, "mocked Driver#create failure"
        end

        specify "should raise a Kitchen::ActionFailed" do
          expect do
            subject.call kitchen_instance_state
          end.to raise_error ::Kitchen::ActionFailed, "mocked Driver#create failure"
        end
      end

      context "when the driver create action is a success" do
        let :variables do
          {}
        end

        let :outputs do
          {}
        end

        before do
          allow(driver).to(receive(:apply) do |&block|
            block.call outputs: { "output_name" => { "value" => "output_value" } }

            driver
          end)
          subject.call kitchen_instance_state
          ::Kitchen::Terraform::VariablesManager.new(logger: kitchen_logger)
            .load(variables: variables, state: kitchen_instance_state)
          ::Kitchen::Terraform::OutputsManager.new(logger: kitchen_logger)
            .load(outputs: outputs, state: kitchen_instance_state)
        end

        specify "should store input variables in the Kitchen instance state" do
          expect(variables).to eq "variable" => "input_value"
        end

        specify "should store output variables in the Kitchen instance state" do
          expect(outputs).to eq "output_name" => { "value" => "output_value" }
        end
      end
    end
  end
end
