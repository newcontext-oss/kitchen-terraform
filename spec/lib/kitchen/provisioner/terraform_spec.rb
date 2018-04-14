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
require "kitchen/provisioner/terraform"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/client_context"
require "support/kitchen/terraform/configurable_examples"

::RSpec
  .describe ::Kitchen::Provisioner::Terraform do
    it_behaves_like "Kitchen::Terraform::Configurable" do
      let :described_instance do
        described_class.new
      end
    end

    describe "#call" do
      include_context "Kitchen::Instance" do
        let :driver do
          ::Kitchen::Driver::Terraform
            .new(
              backend_configurations: {key: "value"},
              color: false,
              kitchen_root: kitchen_root,
              plugin_directory: "/plugin/directory",
              variable_files: ["/variable/file"],
              variables: {key: "value"}
            )
        end

        let :provisioner do
          subject
        end
      end

      include_context "Kitchen::Terraform::Client"

      let :kitchen_root do
        "/kitchen/root"
      end

      let :kitchen_state do
        {}
      end

      before do
        driver.client = client
        subject.finalize_config! instance
      end

      def expect_invoking_method
        expect do
          subject.call kitchen_state
        end
      end

      shared_examples "terraform: get; validate; apply; output" do
        context "when `terraform get` results in failure" do
          before do
            run_command_failure(
              command: /terraform get/,
              message: "mocked `terraform get` failure"
            )
          end

          specify do
            expect_invoking_method
              .to(
                raise_error(
                  ::Kitchen::ActionFailed,
                  "mocked `terraform get` failure"
                )
              )
          end
        end

        context "when `terraform get` results in success" do
          before do
            run_command_success command: "terraform get -update #{kitchen_root}"
          end

          context "when `terraform validate` results in failure" do
            before do
              run_command_failure(
                command: /terraform validate/,
                message: "mocked `terraform validate` failure"
              )
            end

            specify do
              expect_invoking_method
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform validate` failure"
                  )
                )
            end
          end

          context "when `terraform validate` results in success" do
            before do
              run_command_success(
                command:
                  "terraform validate " \
                    "-check-variables=true " \
                    "-no-color " \
                    "-var-file=/variable/file " \
                    "-var=\"key=value\" " \
                    "#{kitchen_root}"
              )
            end

            context "when `terraform apply` results in failure" do
              before do
                run_command_failure(
                  command: /terraform apply/,
                  message: "mocked `terraform apply` failure"
                )
              end

              specify do
                expect_invoking_method
                  .to(
                    raise_error(
                      ::Kitchen::ActionFailed,
                      "mocked `terraform apply` failure"
                    )
                  )
              end
            end

            context "when `terraform apply` results in success" do
              before do
                run_command_success(
                  command:
                    "terraform apply " \
                      "-auto-approve=true " \
                      "-input=false " \
                      "-refresh=true " \
                      "-lock-timeout=0s " \
                      "-lock=true " \
                      "-no-color " \
                      "-parallelism=10 " \
                      "-var-file=/variable/file " \
                      "-var=\"key=value\" " \
                      "#{kitchen_root}"
                )
              end

              shared_context "when `terraform output` results in failure" do
                before do
                  run_command_failure(
                    command: "terraform output -json",
                    message: message
                  )
                end
              end

              context "when `terraform output` results in failure due to no outputs defined" do
                include_context "when `terraform output` results in failure"

                let :message do
                  "no outputs defined"
                end

                before do
                  subject.call kitchen_state
                end

                specify "should store in the Test Kitchen state :kitchen_terraform_output and an empty hash" do
                  expect(kitchen_state.fetch(:kitchen_terraform_output)).to eq({})
                end
              end

              context "when `terraform output` results in failure due to any other reason" do
                include_context "when `terraform output` results in failure"

                let :message do
                  "mocked `terraform output` failure"
                end

                specify do
                  expect_invoking_method
                    .to(
                      raise_error(
                        ::Kitchen::ActionFailed,
                        "mocked `terraform output` failure"
                      )
                    )
                end
              end

              context "when `terraform output` results in success" do
                before do
                  run_command_success(
                    command: "terraform output -json",
                    return_value: terraform_output_value
                  )
                end

                context "when the value of the `terraform output` result is not valid JSON" do
                  let :terraform_output_value do
                    "not valid JSON"
                  end

                  specify do
                    expect_invoking_method
                      .to(
                        raise_error(
                          ::Kitchen::ActionFailed,
                          /Parsing Terraform output as JSON failed:/
                        )
                      )
                  end
                end

                context "when the value of the `terraform output` result is valid JSON" do
                  let :terraform_output_value do
                    ::JSON.dump value_as_hash
                  end

                  let :value_as_hash do
                    {output_name: {value: ["output_value_1"]}}
                  end

                  before do
                    subject.call kitchen_state
                  end

                  specify(
                    "should store in the Test Kitchen state :kitchen_terraform_output and a hash containing the " \
                      "parsed output"
                  ) do
                    expect(kitchen_state.fetch(:kitchen_terraform_output))
                      .to eq "output_name" => {"value" => ["output_value_1"]}
                  end
                end
              end
            end
          end
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in failure" do
        before do
          run_command_failure(
            command: "terraform workspace select kitchen-terraform-suite-platform",
            message: "mocked `terraform workspace select <kitchen-instance>` failure"
          )
        end

        context "when `terraform workspace new <kitchen-instance>` results in failure" do
          before do
            run_command_failure(
              command: "terraform workspace new kitchen-terraform-suite-platform",
              message: "mocked `terraform workspace new <kitchen-instance>` failure"
            )
          end

          specify do
            expect_invoking_method
              .to(
                raise_error(
                  ::Kitchen::ActionFailed,
                  "mocked `terraform workspace new <kitchen-instance>` failure"
                )
              )
          end
        end

        context "when `terraform workspace new <kitchen-instance>` results in success" do
          before do
            run_command_success command: "terraform workspace new kitchen-terraform-suite-platform"
          end

          it_behaves_like "terraform: get; validate; apply; output"
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in success" do
        before do
          run_command_success command: "terraform workspace select kitchen-terraform-suite-platform"
        end

        it_behaves_like "terraform: get; validate; apply; output"
      end
    end
  end
