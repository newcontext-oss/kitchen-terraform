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

require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/provisioner/terraform"
require "kitchen/terraform/error"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Provisioner::Terraform do
  subject do
    described_class.new config
  end

  let :config do
    {}
  end

  it_behaves_like "Kitchen::Terraform::Configurable" do
    let :described_instance do
      described_class.new config
    end
  end

  describe "#call" do
    let :driver do
      ::Kitchen::Driver::Terraform.new
    end

    let :kitchen_instance do
      ::Kitchen::Instance.new driver: driver, lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
                              logger: ::Kitchen::Logger.new, platform: ::Kitchen::Platform.new(name: "test-platform"),
                              provisioner: described_instance,
                              state_file: ::Kitchen::StateFile.new("/kitchen/root", "test-suite-test-platform"),
                              suite: ::Kitchen::Suite.new(name: "test-suite"),
                              transport: ::Kitchen::Transport::Base.new, verifier: ::Kitchen::Verifier::Base.new
    end

    let :kitchen_state do
      {}
    end

    before do
      subject.finalize_config! kitchen_instance
    end

    describe "error handling" do
      context "when the driver create action is a failure" do
        before do
          allow(driver).to receive(:apply).and_raise ::Kitchen::ActionFailed, "mocked Driver#create failure"
        end

        specify "should raise a Kitchen::ActionFailed" do
          expect do
            subject.call kitchen_state
          end.to raise_error ::Kitchen::ActionFailed, "mocked Driver#create failure"
        end
      end

      context "when the driver create action is a success" do
        before do
          allow(driver).to receive :apply
        end

        specify "should not raise an error" do
          expect do
            subject.call kitchen_state
          end.to_not raise_error
        end
      end
    end
  end
end
