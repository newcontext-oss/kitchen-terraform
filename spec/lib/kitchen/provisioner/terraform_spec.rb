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

::RSpec
  .describe ::Kitchen::Provisioner::Terraform do
    let :described_instance do
      described_class.new({})
    end

    it_behaves_like "Kitchen::Terraform::Configurable"

    describe "#call" do
      subject do
        lambda do
          described_instance.call kitchen_state
        end
      end

      let :driver do
        ::Kitchen::Driver::Terraform.new
      end

      let :kitchen_instance do
        ::Kitchen::Instance
          .new(
            driver: driver,
            logger: ::Kitchen::Logger.new,
            platform: ::Kitchen::Platform.new(name: "test-platform"),
            provisioner: described_instance,
            state_file:
              ::Kitchen::StateFile
                .new(
                  "/kitchen/root",
                  "test-suite-test-platform"
                ),
            suite: ::Kitchen::Suite.new(name: "test-suite"),
            transport: ::Kitchen::Transport::Base.new,
            verifier: ::Kitchen::Verifier::Base.new
          )
      end

      let :kitchen_state do
        {}
      end

      before do
        described_instance.finalize_config! kitchen_instance
      end

      describe "error handling" do
        context "when the driver create action is a failure" do
          before do
            allow(driver)
              .to(
                receive(:apply)
                  .and_raise(
                    ::Kitchen::Terraform::Error,
                    "mocked Driver#create failure"
                  )
              )
          end

          it do
            is_expected
              .to(
                raise_error(
                  ::Kitchen::ActionFailed,
                  "mocked Driver#create failure"
                )
              )
          end
        end

        context "when the driver create action is a success" do
          before do
            allow(driver).to receive(:apply).and_yield output: "mocked Driver#create output"
          end

          it do
            is_expected.to_not raise_error
          end
        end
      end

      describe "Test Kitchen state manipulation" do
        subject do
          kitchen_state
        end

        before do
          allow(driver).to receive(:apply).and_yield output: "mocked Driver#create output"
          described_instance.call kitchen_state
        end

        it do
          is_expected.to include kitchen_terraform_output: "mocked Driver#create output"
        end
      end
    end
  end
