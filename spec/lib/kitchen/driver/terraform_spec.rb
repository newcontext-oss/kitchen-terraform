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
require "kitchen/terraform/change_workspace"
require "kitchen/terraform/command/apply"
require "kitchen/terraform/command/destroy"
require "kitchen/terraform/command/get"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/validate"
require "kitchen/terraform/command/workspace_delete"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/error"
require "kitchen/terraform/verify_version"
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
require "support/kitchen/terraform/config_attribute/verify_version_examples"
require "support/kitchen/terraform/configurable_examples"
require "support/kitchen/terraform/result_in_failure_matcher"
require "support/kitchen/terraform/result_in_success_matcher"

::RSpec.describe ::Kitchen::Driver::Terraform do
  let :config do
    {
      backend_configurations: config_backend_configurations,
      color: config_color,
      command_timeout: config_command_timeout,
      lock: config_lock,
      lock_timeout: config_lock_timeout,
      parallelism: config_parallelism,
      plugin_directory: config_plugin_directory,
      root_module_directory: config_root_module_directory,
      variable_files: config_variable_files,
      variables: config_variables,
      verify_version: config_verify_version,
    }
  end

  let :config_backend_configurations do
    {
      list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
      map: "{ key = \\\"A Value\\\" }",
      string: "\\\"A String\\\"",
    }
  end

  let :config_color do
    false
  end

  let :config_lock_timeout do
    1234
  end

  let :config_command_timeout do
    1234
  end

  let :config_lock do
    false
  end

  let :config_root_module_directory do
    "/root-module-directory"
  end

  let :config_parallelism do
    1234
  end

  let :config_plugin_directory do
    "/Arbitrary Directory/Plugin Directory"
  end

  let :config_variable_files do
    ["/Arbitrary Directory/Variable File.tfvars"]
  end

  let :config_variables do
    {
      string: "\\\"A String\\\"",
      map: "{ key = \\\"A Value\\\" }",
      list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
    }
  end

  let :config_verify_version do
    true
  end

  let :described_instance do
    described_class.new config
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new driver: described_instance, lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
                            logger: kitchen_logger, platform: ::Kitchen::Platform.new(name: "test-platform"),
                            provisioner: ::Kitchen::Provisioner::Base.new,
                            state_file: ::Kitchen::StateFile.new("/kitchen", "test-suite-test-platform"),
                            suite: ::Kitchen::Suite.new(name: "test-suite"), transport: ::Kitchen::Transport::Base.new,
                            verifier: ::Kitchen::Verifier::Base.new
  end

  let :kitchen_logger do
    described_instance.send :logger
  end

  let :instance_workspace_name do
    "kitchen-terraform-test-suite-test-platform"
  end

  shared_context "Terraform CLI available" do
    before do
      allow(::TTY::Which).to receive(:exist?).with("terraform").and_return true
    end
  end

  shared_examples "the action fails if the Terraform version is unsupported" do
    let :error_message do
      "mocked VerifyVersion failure"
    end

    before do
      allow(::Kitchen::Terraform::VerifyVersion).to receive(:call).and_raise(
        ::Kitchen::Terraform::Error, error_message
      )
    end

    specify "should result in an action failed error with the failed command output" do
      expect do
        action
      end.to raise_error ::Kitchen::ActionFailed, error_message
    end
  end

  shared_examples "the action fails if the Terraform workspace can not be changed" do
    before do
      allow(::Kitchen::Terraform::ChangeWorkspace).to receive(:call).with(
        directory: config_root_module_directory,
        name: instance_workspace_name,
        timeout: config_command_timeout,
      ).and_raise ::Kitchen::Terraform::Error, "mocked changing workspace failure"
    end

    specify "should raise an action failed error with the failed command output" do
      expect do
        action
      end.to raise_error ::Kitchen::ActionFailed, "mocked changing workspace failure"
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

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::VerifyVersion"

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe ".serial_actions" do
    specify "actions are returned" do
      expect(described_class.serial_actions)
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

  describe "#apply" do
    subject do
      described_instance
    end

    include_context "Terraform CLI available"

    before do
      described_instance.finalize_config! kitchen_instance
    end

    shared_examples "it changes to the instance workspace and generates the state" do
      it_behaves_like "the action fails if the Terraform workspace can not be changed" do
        let :action do
          subject.apply
        end
      end

      context "when the workspace can be change" do
        before do
          allow(::Kitchen::Terraform::ChangeWorkspace).to receive(:call).with(
            directory: config_root_module_directory,
            name: instance_workspace_name,
            timeout: config_command_timeout,
          )
        end

        context "when `terraform get` results in failure" do
          before do
            allow(::Kitchen::Terraform::Command::Get).to receive(:run).with(
              directory: config_root_module_directory,
              timeout: config_command_timeout,
            ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform get` failure"
          end

          specify "should result in an action failed error with the failed command output" do
            expect do
              subject.apply
            end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform get` failure"
          end
        end

        context "when `terraform get` results in success" do
          before do
            allow(::Kitchen::Terraform::Command::Get).to receive(:run).with(
              directory: config_root_module_directory,
              timeout: config_command_timeout,
            )
          end

          context "when `terraform validate` results in failure" do
            before do
              allow(::Kitchen::Terraform::Command::Validate).to receive(:run).with(
                color: config_color,
                directory: config_root_module_directory,
                variable_files: config_variable_files,
                variables: config_variables,
                timeout: config_command_timeout,
              ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform validate` failure"
            end

            specify "should result in an action failed error with the failed command output" do
              expect do
                subject.apply
              end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform validate` failure"
            end
          end

          context "when `terraform validate` results in success" do
            before do
              allow(::Kitchen::Terraform::Command::Validate).to receive(:run).with(
                color: config_color,
                directory: config_root_module_directory,
                variable_files: config_variable_files,
                variables: config_variables,
                timeout: config_command_timeout,
              )
            end

            context "when `terraform apply` results in failure" do
              before do
                allow(::Kitchen::Terraform::Command::Apply).to receive(:run).with(
                  color: config_color,
                  directory: config_root_module_directory,
                  lock: config_lock,
                  lock_timeout: config_lock_timeout,
                  parallelism: config_parallelism,
                  timeout: config_command_timeout,
                  variable_files: config_variable_files,
                  variables: config_variables,
                ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform apply` failure"
              end

              specify "should result in an action failed error with the failed command output" do
                expect do
                  subject.apply
                end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform apply` failure"
              end
            end

            context "when `terraform apply` results in success" do
              before do
                allow(::Kitchen::Terraform::Command::Apply).to receive(:run).with(
                  color: config_color,
                  directory: config_root_module_directory,
                  lock: config_lock,
                  lock_timeout: config_lock_timeout,
                  parallelism: config_parallelism,
                  timeout: config_command_timeout,
                  variable_files: config_variable_files,
                  variables: config_variables,
                )
              end

              specify "should result in success" do
                expect do
                  subject.apply
                end.not_to raise_error
              end
            end
          end
        end
      end
    end

    it_behaves_like "the action fails if the Terraform version is unsupported" do
      let :action do
        subject.apply
      end
    end

    context "when the Terraform version is unsupported but verification is disabled" do
      let :config_verify_version do
        false
      end

      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive(:call).and_raise ::Kitchen::Terraform::Error
      end

      it_behaves_like "it changes to the instance workspace and generates the state"
    end

    context "when the Terraform version is supported" do
      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive :call
      end

      it_behaves_like "it changes to the instance workspace and generates the state"
    end
  end

  describe "#create" do
    subject do
      described_instance
    end

    include_context "Terraform CLI available"

    before do
      described_instance.finalize_config! kitchen_instance
    end

    shared_examples "it initializes the root module and selects the instance workspace" do
      context "when `terraform init` results in failure" do
        before do
          allow(::Kitchen::Terraform::Command::Init).to receive(:run).with(
            backend_config: config_backend_configurations,
            color: config_color,
            directory: config_root_module_directory,
            lock: config_lock,
            lock_timeout: config_lock_timeout,
            plugin_dir: config_plugin_directory,
            timeout: config_command_timeout,
            upgrade: true,
          ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform init` failure"
        end

        specify "should result in an action failed error with the failed command output" do
          expect do
            subject.create({})
          end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform init` failure"
        end
      end

      context "when `terraform init` results in success" do
        before do
          allow(::Kitchen::Terraform::Command::Init).to receive(:run).with(
            backend_config: config_backend_configurations,
            color: config_color,
            directory: config_root_module_directory,
            lock: config_lock,
            lock_timeout: config_lock_timeout,
            plugin_dir: config_plugin_directory,
            timeout: config_command_timeout,
            upgrade: true,
          )
        end

        it_behaves_like "the action fails if the Terraform workspace can not be changed" do
          let :action do
            subject.create({})
          end
        end

        context "when the workspace can be changed" do
          before do
            allow(::Kitchen::Terraform::ChangeWorkspace).to receive(:call).with(
              directory: config_root_module_directory,
              name: instance_workspace_name,
              timeout: config_command_timeout,
            )
          end

          specify "should result in success" do
            expect do
              subject.create({})
            end.not_to raise_error
          end
        end
      end
    end

    it_behaves_like "the action fails if the Terraform version is unsupported" do
      let :action do
        subject.create({})
      end
    end

    it_behaves_like "the action fails if the Terraform version is unsupported" do
      let :action do
        subject.create({})
      end
    end

    context "when the Terraform version is unsupported but verification is disabled" do
      let :config_verify_version do
        false
      end

      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive(:call).and_raise ::Kitchen::Terraform::Error
      end

      it_behaves_like "it initializes the root module and selects the instance workspace"
    end

    context "when the Terraform version is supported" do
      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive :call
      end

      it_behaves_like "it initializes the root module and selects the instance workspace"
    end
  end

  describe "#destroy" do
    subject do
      described_instance
    end

    include_context "Terraform CLI available"

    let :config_plugin_directory do
      nil
    end

    before do
      described_instance.finalize_config! kitchen_instance
    end

    shared_examples "it initializes the root module, selects the instance workspace, and destroys the state" do
      context "when `terraform init` results in failure" do
        before do
          allow(::Kitchen::Terraform::Command::Init).to receive(:run).with(
            backend_config: config_backend_configurations,
            color: config_color,
            directory: config_root_module_directory,
            lock: config_lock,
            lock_timeout: config_lock_timeout,
            plugin_dir: config_plugin_directory,
            timeout: config_command_timeout,
            upgrade: false,
          ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform init` failure"
        end

        specify "should result in an action failed error with the failed command output" do
          expect do
            subject.destroy({})
          end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform init` failure"
        end
      end

      context "when `terraform init` results in success" do
        before do
          allow(::Kitchen::Terraform::Command::Init).to receive(:run).with(
            backend_config: config_backend_configurations,
            color: config_color,
            directory: config_root_module_directory,
            lock: config_lock,
            lock_timeout: config_lock_timeout,
            plugin_dir: config_plugin_directory,
            timeout: config_command_timeout,
            upgrade: false,
          )
        end

        it_behaves_like "the action fails if the Terraform workspace can not be changed" do
          let :action do
            subject.destroy({})
          end
        end

        context "when the workspace can be changed" do
          before do
            allow(::Kitchen::Terraform::ChangeWorkspace).to receive(:call).with(
              directory: config_root_module_directory,
              name: instance_workspace_name,
              timeout: config_command_timeout,
            )
          end

          let :action do
            subject.destroy({})
          end

          context "when `terraform destroy` results in failure" do
            before do
              allow(::Kitchen::Terraform::Command::Destroy).to receive(:run).with(
                color: config_color,
                directory: config_root_module_directory,
                lock: config_lock,
                lock_timeout: config_lock_timeout,
                parallelism: config_parallelism,
                timeout: config_command_timeout,
                variable_files: config_variable_files,
                variables: config_variables,
              ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform destroy` failure"
            end

            specify "should result in an action failed error with the failed command output" do
              expect do
                action
              end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform destroy` failure"
            end
          end

          context "when `terraform destroy` results in success" do
            let :default_workspace_name do
              "default"
            end

            before do
              allow(::Kitchen::Terraform::Command::Destroy).to receive(:run).with(
                color: config_color,
                directory: config_root_module_directory,
                lock: config_lock,
                lock_timeout: config_lock_timeout,
                parallelism: config_parallelism,
                timeout: config_command_timeout,
                variable_files: config_variable_files,
                variables: config_variables,
              )
            end

            context "when `terraform select default` results in failure" do
              before do
                allow(::Kitchen::Terraform::Command::WorkspaceSelect).to receive(:run).with(
                  directory: config_root_module_directory,
                  name: default_workspace_name,
                  timeout: config_command_timeout,
                ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform workspace select default` failure"
              end

              specify "should result in an action failed error with the failed command output" do
                expect do
                  action
                end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform workspace select default` failure"
              end
            end

            context "when `terraform workspace select default` results in success" do
              before do
                allow(::Kitchen::Terraform::Command::WorkspaceSelect).to receive(:run).with(
                  directory: config_root_module_directory,
                  name: default_workspace_name,
                  timeout: config_command_timeout,
                )
              end

              context "when `terraform workspace delete <kitchen-instance>` results in failure" do
                before do
                  allow(::Kitchen::Terraform::Command::WorkspaceDelete).to receive(:run).with(
                    directory: config_root_module_directory,
                    name: instance_workspace_name,
                    timeout: config_command_timeout,
                  ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform workspace delete <kitchen-instance>` failure"
                end

                specify "should result in an action failed error with the failed command output" do
                  expect do
                    action
                  end.to raise_error(
                    ::Kitchen::ActionFailed,
                    "mocked `terraform workspace delete <kitchen-instance>` failure"
                  )
                end
              end

              context "when `terraform workspace delete <kitchen-instance>` results in success" do
                before do
                  allow(::Kitchen::Terraform::Command::WorkspaceDelete).to receive(:run).with(
                    directory: config_root_module_directory,
                    name: instance_workspace_name,
                    timeout: config_command_timeout,
                  )
                end

                specify "should result in success" do
                  expect do
                    action
                  end.not_to raise_error
                end
              end
            end
          end
        end
      end
    end

    it_behaves_like "the action fails if the Terraform version is unsupported" do
      let :action do
        subject.destroy({})
      end
    end

    it_behaves_like "the action fails if the Terraform version is unsupported" do
      let :action do
        subject.destroy({})
      end
    end

    context "when the Terraform version is unsupported but verification is disabled" do
      let :config_verify_version do
        false
      end

      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive(:call).and_raise ::Kitchen::Terraform::Error
      end

      it_behaves_like "it initializes the root module, selects the instance workspace, and destroys the state"
    end

    context "when the Terraform version is supported" do
      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive :call
      end

      it_behaves_like "it initializes the root module, selects the instance workspace, and destroys the state"
    end
  end

  describe "#retrieve_outputs" do
    subject do
      described_instance
    end

    before do
      described_instance.finalize_config! kitchen_instance
    end

    it_behaves_like "the action fails if the Terraform workspace can not be changed" do
      let :action do
        subject.retrieve_outputs
      end
    end

    context "when the workspace can be changed" do
      before do
        allow(::Kitchen::Terraform::ChangeWorkspace).to receive(:call).with(
          directory: config_root_module_directory,
          name: instance_workspace_name,
          timeout: config_command_timeout,
        )
      end

      context "when the command results in failure not due to no outputs defined" do
        before do
          allow(::Kitchen::Terraform::Command::Output).to receive(:run).with(
            color: config_color,
            directory: config_root_module_directory,
            timeout: config_command_timeout,
          ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform output` failure"
        end

        specify "should result in an action failed error with the failed command output" do
          expect do
            subject.retrieve_outputs
          end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform output` failure"
        end
      end

      context "when the command results in success" do
        let :output do
          ::Kitchen::Terraform::Command::Output.new color: config_color
        end

        before do
          output.store output: ::JSON.dump({output_name: {sensitive: false, type: "list", value: ["output_value_1"]}})
          allow(::Kitchen::Terraform::Command::Output).to receive(:run).with(
            color: config_color,
            directory: config_root_module_directory,
            timeout: config_command_timeout,
          ).and_yield output: output
        end

        specify "should yield the hash which results from processing the output as JSON" do
          expect do |block|
            subject.retrieve_outputs(&block)
          end.to yield_with_args(
            outputs: {
              "output_name" => {
                "sensitive" => false,
                "type" => "list",
                "value" => ["output_value_1"],
              },
            },
          )
        end
      end
    end
  end

  describe "#verify_dependencies" do
    subject do
      described_instance
    end

    context "when the Terraform CLI is not found on the PATH" do
      before do
        allow(::TTY::Which).to receive(:exist?).with("terraform").and_return false
      end

      specify "should result in a user error which indicates the CLI was not found on the PATH" do
        expect do
          subject.verify_dependencies
        end.to raise_error ::Kitchen::UserError, "The Terraform CLI was not found on the PATH"
      end
    end

    context "when the Terraform CLI is found on the PATH" do
      include_context "Terraform CLI available"

      specify "should not result in an error" do
        expect do
          subject.verify_dependencies
        end.not_to raise_error
      end
    end
  end
end
