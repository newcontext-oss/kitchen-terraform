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

require "json"
require "kitchen"
require "kitchen/driver/terraform"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/client_dependency_examples"
require "support/kitchen/terraform/config_attribute/backend_configurations_examples"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/command_timeout_examples"
require "support/kitchen/terraform/config_attribute/lock_examples"
require "support/kitchen/terraform/config_attribute/lock_timeout_examples"
require "support/kitchen/terraform/config_attribute/parallelism_examples"
require "support/kitchen/terraform/config_attribute/plugin_directory_examples"
require "support/kitchen/terraform/config_attribute/root_module_directory_examples"
require "support/kitchen/terraform/config_attribute/variable_files_examples"
require "support/kitchen/terraform/config_attribute/variables_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec
  .describe ::Kitchen::Driver::Terraform do
    include_context "Kitchen::Instance" do
      let :driver do
        described_instance
      end
    end

    let :config do
      {
        backend_configurations: {key: "value"},
        color: false,
        kitchen_root: kitchen_root,
        plugin_directory: "/plugin/directory",
        variable_files: ["/variable/file"],
        variables: {key: "value"}
      }
    end

    let :described_instance do
      described_class.new config
    end

    it_behaves_like "Kitchen::Terraform::ClientDependency" do
      subject do
        described_instance
      end
    end

    it_behaves_like "Kitchen::Terraform::ConfigAttribute::BackendConfigurations"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::CommandTimeout"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Lock"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::LockTimeout"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Parallelism"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::PluginDirectory"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::RootModuleDirectory"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::VariableFiles"
    it_behaves_like "Kitchen::Terraform::ConfigAttribute::Variables"
    it_behaves_like "Kitchen::Terraform::Configurable"

    describe ".serial_actions" do
      shared_examples "actions are returned" do
        specify do
          /^2.2/
            .match ::RUBY_VERSION and
            skip "Not applicable to Ruby v2.2"

          expect(described_class.serial_actions(version: version))
            .to(
              contain_exactly(
                :create,
                :converge,
                :setup,
                :destroy
              )
            )
        end
      end

      context "when the version is less than 4.0.0" do
        specify do
          expect(described_class.serial_actions(version: ::Kitchen::Terraform::Version.new(version: "3.3.0")))
            .to be_empty
        end
      end

      context "when the version is equal to 4.0.0" do
        let :version do
          ::Kitchen::Terraform::Version.new version: "4.0.0"
        end

        it_behaves_like "actions are returned"
      end

      context "when the version is greater than 4.0.0" do
        let :version do
          ::Kitchen::Terraform::Version.new version: "5.6.7"
        end

        it_behaves_like "actions are returned"
      end
    end

    describe "#create" do
      subject do
        described_instance
      end

      before do
        described_instance.finalize_config! instance
      end

      def expect_invoking_method
        expect do
          subject.create({})
        end
      end

      context "when `terraform init` results in failure" do
        before do
          run_general_command_failure(
            command: :init,
            message: "mocked `terraform init` failure"
          )
        end

        specify do
          expect_invoking_method
            .to(
              raise_error(
                ::Kitchen::ActionFailed,
                "mocked `terraform init` failure"
              )
            )
        end
      end

      context "when `terraform init` results in success" do
        before do
          run_specific_command_success(
            command: :init,
            flags:
              [
                "-backend=true",
                "-force-copy",
                "-get-plugins=true",
                "-get=true",
                "-input=false",
                "-upgrade",
                "-verify-plugins=true",
                "-backend-config=key\=value",
                "-lock-timeout=0s",
                "-lock=true",
                "-no-color",
                "-plugin-dir=/plugin/directory"
              ]
          )
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
            run_general_command_success command: :within_kitchen_instance_workspace
          end

          specify do
            expect_invoking_method.to_not raise_error
          end
        end
      end
    end

    describe "#destroy" do
      subject do
        described_instance
      end

      before do
        described_instance.finalize_config! instance
      end

      def expect_invoking_method
        expect do
          subject.destroy({})
        end
      end

      context "when `terraform init` results in failure" do
        before do
          run_general_command_failure(
            command: :init,
            message: "mocked `terraform init` failure"
          )
        end

        specify do
          expect_invoking_method
            .to(
              raise_error(
                ::Kitchen::ActionFailed,
                "mocked `terraform init` failure"
              )
            )
        end
      end

      context "when `terraform init` results in success" do
        before do
          run_specific_command_success(
            command: :init,
            flags:
              [
                "-backend=true",
                "-force-copy",
                "-get-plugins=true",
                "-get=true",
                "-input=false",
                "-verify-plugins=true",
                "-backend-config=key\=value",
                "-lock-timeout=0s",
                "-lock=true",
                "-no-color",
                "-plugin-dir=/plugin/directory"
              ]
          )
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

          context "when `terraform destroy` results in failure" do
            before do
              run_general_command_failure(
                command: :destroy,
                message: "mocked `terraform destroy` failure"
              )
            end

            specify do
              expect_invoking_method
                .to(
                  raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform destroy` failure"
                  )
                )
            end
          end

          context "when `terraform destroy` results in success" do
            before do
              run_specific_command_success(
                command: :destroy,
                flags:
                  [
                    "-force",
                    "-input=false",
                    "-refresh=true",
                    "-lock-timeout=0s",
                    "-lock=true",
                    "-no-color",
                    "-parallelism=10",
                    "-var-file=/variable/file",
                    "-var=key\=value"
                  ]
              )
            end

            context "when `terraform workspace delete <kitchen-instance>` results in failure" do
              before do
                run_general_command_failure(
                  command: :delete_kitchen_instance_workspace,
                  message: "mocked `terraform workspace delete <kitchen-instance>` failure"
                )
              end

              specify do
                expect_invoking_method
                  .to(
                    raise_error(
                      ::Kitchen::ActionFailed,
                      "mocked `terraform workspace delete <kitchen-instance>` failure"
                    )
                  )
              end
            end

            context "when `terraform workspace delete <kitchen-instance>` results in success" do
              before do
                run_general_command_success command: :delete_kitchen_instance_workspace
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
