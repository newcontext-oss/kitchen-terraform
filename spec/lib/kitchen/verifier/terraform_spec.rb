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
require "kitchen"
require "kitchen/verifier/terraform"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/groups_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec
  .describe ::Kitchen::Verifier::Terraform do
    let :described_instance do
      described_class
        .new(
          groups:
            [
              {
                attributes: {attribute_name: "output_name"},
                controls: ["control"],
                hostnames: "hostnames",
                name: "name",
                port: 1234,
                ssh_key: "ssh_key",
                username: "username"
              }
            ],
          test_base_path: "/test/base/path"
        )
    end

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Groups"

    it_behaves_like "Kitchen::Terraform::Configurable"

    describe "#call" do
      subject do
        lambda do
          described_instance.call kitchen_state
        end
      end

      let :kitchen_instance do
        ::Kitchen::Instance
          .new(
            driver: ::Kitchen::Driver::Base.new,
            logger: ::Kitchen::Logger.new,
            platform: ::Kitchen::Platform.new(name: "test-platform"),
            provisioner: ::Kitchen::Provisioner::Base.new,
            state_file:
              ::Kitchen::StateFile
                .new(
                  "/kitchen/root",
                  "test-suite-test-platform"
                ),
            suite: ::Kitchen::Suite.new(name: "test-suite"),
            transport: ::Kitchen::Transport::Ssh.new,
            verifier: described_instance
          )
      end

      before do
        described_instance.finalize_config! kitchen_instance
      end

      context "when the Test Kitchen state omits :kitchen_terraform_output" do
        let :kitchen_state do
          {}
        end

        it do
          is_expected
            .to(
              raise_error(
                ::Kitchen::ActionFailed,
                "The Test Kitchen state does not include :kitchen_terraform_output; this implies that the " \
                  "kitchen-terraform provisioner has not successfully converged"
              )
            )
        end
      end

      context "when the Test Kitchen state includes :kitchen_terraform_output" do
        let :kitchen_state do
          {kitchen_terraform_output: kitchen_terraform_output}
        end

        context "when the :kitchen_terraform_output does not include the configured :hostnames key" do
          let :kitchen_terraform_output do
            {}
          end

          it "raise an action failed error" do
            is_expected
              .to(
                raise_error(
                  ::Kitchen::ActionFailed,
                  /Enumeration of groups and hostnames resulted in failure/
                )
              )
          end
        end

        context "when the :kitchen_terraform_output does include the configured :hostnames key" do
          let :runner do
            instance_double ::Inspec::Runner
          end

          let :runner_class do
            class_double(::Inspec::Runner).as_stubbed_const
          end

          let :kitchen_terraform_output do
            {
              "output_name" => {"value" => "output_value"},
              "hostnames" => {"value" => "hostname"}
            }
          end

          before do
            allow(runner_class)
              .to(
                receive(:new)
                  .with(
                    including(
                      attributes: {
                        "attribute_name" => "output_value",
                        "hostnames" => "hostname",
                        "output_name" => "output_value"
                      },
                      "backend" => "ssh",
                      controls: ["control"],
                      "host" => "hostname",
                      "key_files" => ["ssh_key"],
                      "port" => 1234,
                      "user" => "username"
                    )
                  )
                  .and_return(runner)
              )

            allow(runner)
              .to(
                receive(:run)
                  .with(no_args)
                  .and_return(exit_code)
              )
          end

          context "when the InSpec runner returns an exit code other than 0" do
            let :exit_code do
              1
            end

            it "does raise an error" do
              is_expected
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "Inspec Runner returns 1"
                  )
                )
            end
          end

          context "when the InSpec runner returns an exit code of 0" do
            let :exit_code do
              0
            end

            it "does not raise an error" do
              is_expected.to_not raise_error
            end
          end
        end
      end
    end
  end
