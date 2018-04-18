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
require "support/kitchen/terraform/client_dependency_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec
  .describe ::Kitchen::Provisioner::Terraform do
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
        described_instance
      end
    end

    let :described_instance do
      described_class.new
    end

    it_behaves_like "Kitchen::Terraform::ClientDependency" do
      subject do
        described_instance
      end
    end

    it_behaves_like "Kitchen::Terraform::Configurable"

    describe "#call" do
      subject do
        described_instance
      end

      let :kitchen_state do
        {}
      end

      before do
        subject.finalize_config! instance
      end

      def expect_invoking_method
        expect do
          subject.call kitchen_state
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in failure" do
        before do
          run_general_command_failure(
            command: :within_kitchen_instance_workspace,
            message: "mocked `terraform workspace select <kitchen-instance>` failure"
          )
        end

        specify do
          expect_invoking_method
            .to(
              raise_error(
                ::Kitchen::ActionFailed,
                "mocked `terraform workspace select <kitchen-instance>` failure"
              )
            )
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in success" do
        before do
          allow(client).to receive(:within_kitchen_instance_workspace).and_yield
        end

        context "when `terraform get` results in failure" do
          before do
            run_general_command_failure(
              command: :get,
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
            run_specific_command_success(
              command: :get,
              flags: ["-update"]
            )
          end

          context "when `terraform validate` results in failure" do
            before do
              run_general_command_failure(
                command: :validate,
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
              run_specific_command_success(
                command: :validate,
                flags:
                  [
                    "-check-variables=true",
                    "-no-color",
                    "-var-file=/variable/file",
                    "-var=\"key=value\""
                  ]
              )
            end

            context "when `terraform apply` results in failure" do
              before do
                run_general_command_failure(
                  command: :apply,
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
                run_specific_command_success(
                  command: :apply,
                  flags:
                    [
                      "-auto-approve=true",
                      "-input=false",
                      "-refresh=true",
                      "-lock-timeout=0s",
                      "-lock=true",
                      "-no-color",
                      "-parallelism=10",
                      "-var-file=/variable/file",
                      "-var=\"key=value\""
                    ]
                )
              end

              context "when `terraform output` results in failure" do
                before do
                  run_general_command_failure(
                    command: :output,
                    message: "mocked `terraform output` failure"
                  )
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
                  run_general_command_success command: :output
                end

                specify do
                  expect_invoking_method.to_not raise_error
                end
              end
            end
          end
        end
      end
    end
  end
