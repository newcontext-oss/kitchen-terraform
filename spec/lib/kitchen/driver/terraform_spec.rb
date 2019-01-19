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
require "kitchen/terraform/error"
require "kitchen/terraform/shell_out"
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
  let :command_timeout do
    1234
  end

  let :config do
    {
      backend_configurations: {
        string: "\\\"A String\\\"", map: "{ key = \\\"A Value\\\" }",
        list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
      },
      color: false,
      command_timeout: command_timeout,
      kitchen_root: kitchen_root,
      plugin_directory: plugin_directory,
      variable_files: ["/Arbitrary Directory/Variable File.tfvars"],
      variables: {
        string: "\\\"A String\\\"", map: "{ key = \\\"A Value\\\" }",
        list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
      },
      verify_version: verify_version,
    }
  end

  let :described_instance do
    described_class.new config
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new driver: described_instance, lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
                            logger: kitchen_logger, platform: ::Kitchen::Platform.new(name: "test-platform"),
                            provisioner: ::Kitchen::Provisioner::Base.new,
                            state_file: ::Kitchen::StateFile.new(kitchen_root, "test-suite-test-platform"),
                            suite: ::Kitchen::Suite.new(name: "test-suite"), transport: ::Kitchen::Transport::Base.new,
                            verifier: ::Kitchen::Verifier::Base.new
  end

  let :kitchen_logger do
    described_instance.send :logger
  end

  let :kitchen_root do
    "/kitchen/root"
  end

  let :plugin_directory do
    "/Arbitrary Directory/Plugin Directory"
  end

  let :shell_out do
    class_double(::Kitchen::Terraform::ShellOut).as_stubbed_const
  end

  let :verify_version do
    true
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

  shared_examples "the action fails if the Terraform root module can not be initialized" do
    before do
      shell_out_run_failure command: /init/, message: "mocked `terraform init` failure"
    end

    specify "should result in an action failed error with the failed command output" do
      expect do
        action
      end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform init` failure"
    end
  end

  shared_examples "the action fails if the Terraform workspace can not be selected or created" do
    before do
      shell_out_run_failure(
        command: "workspace select kitchen-terraform-test-suite-test-platform",
        message: "mocked `terraform workspace select <kitchen-instance>` failure",
      )
      shell_out_run_failure(
        command: "workspace new kitchen-terraform-test-suite-test-platform",
        message: "mocked `terraform workspace new <kitchen-instance>` failure",
      )
    end

    specify "should result in an action failed error with the failed command output" do
      expect do
        action
      end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform workspace new <kitchen-instance>` failure"
    end
  end

  def shell_out_run_failure(command:, message: "mocked `terraform` failure", working_directory: kitchen_root)
    allow(shell_out)
      .to(
        receive(:run)
          .with(
            command: command,
            options: {
              cwd: working_directory,
              live_stream: kitchen_logger,
              timeout: command_timeout,
            },
          )
          .and_raise(
            ::Kitchen::Terraform::Error,
            message
          )
      )
  end

  def shell_out_run_success(command:, return_value: "mocked `terraform` success", working_directory: kitchen_root)
    allow(shell_out)
      .to(
        receive(:run)
          .with(
            command: command,
            options: {
              cwd: working_directory,
              live_stream: kitchen_logger,
              timeout: command_timeout,
            },
          )
          .and_return(return_value)
      )
  end

  def shell_out_run_yield(command:, standard_output: "mocked `terraform` success")
    allow(shell_out)
      .to(
        receive(:run)
          .with(
            command: command,
            options: {
              cwd: kitchen_root,
              live_stream: kitchen_logger,
              timeout: command_timeout,
            },
          )
          .and_yield(standard_output: standard_output)
      )
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

    shared_examples "terraform: get; validate; apply" do
      context "when `terraform get` results in failure" do
        before do
          shell_out_run_failure command: /get/, message: "mocked `terraform get` failure"
        end

        specify "should result in an action failed error with the failed command output" do
          expect do
            subject.apply
          end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform get` failure"
        end
      end

      context "when `terraform get` results in success" do
        before do
          shell_out_run_success command: "get -update"
        end

        context "when `terraform validate` results in failure" do
          before do
            shell_out_run_failure command: /validate/, message: "mocked `terraform validate` failure"
          end

          specify "should result in an action failed error with the failed command output" do
            expect do
              subject.apply
            end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform validate` failure"
          end
        end

        context "when `terraform validate` results in success" do
          before do
            shell_out_run_success(
              command: "validate " \
              "-no-color " \
              "-var=\"string=\\\"A String\\\"\" " \
              "-var=\"map={ key = \\\"A Value\\\" }\" " \
              "-var=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
              "-var-file=\"/Arbitrary Directory/Variable File.tfvars\"",
            )
          end

          context "when `terraform apply` results in failure" do
            before do
              shell_out_run_failure command: /apply/, message: "mocked `terraform apply` failure"
            end

            specify "should result in an action failed error with the failed command output" do
              expect do
                subject.apply
              end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform apply` failure"
            end
          end

          context "when `terraform apply` results in success" do
            before do
              shell_out_run_success(
                command: "apply " \
                "-lock=true " \
                "-lock-timeout=0s " \
                "-input=false " \
                "-auto-approve=true " \
                "-no-color " \
                "-parallelism=10 " \
                "-refresh=true " \
                "-var=\"string=\\\"A String\\\"\" " \
                "-var=\"map={ key = \\\"A Value\\\" }\" " \
                "-var=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
                "-var-file=\"/Arbitrary Directory/Variable File.tfvars\"",
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

    shared_examples "it selects the instance workspace and generates the state" do
      it_behaves_like "the action fails if the Terraform workspace can not be selected or created" do
        let :action do
          subject.apply
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in failure" do
        before do
          shell_out_run_failure(
            command: "workspace select kitchen-terraform-test-suite-test-platform",
            message: "mocked `terraform workspace select <kitchen-instance>` failure",
          )
        end

        context "when `terraform workspace new <kitchen-instance>` results in success" do
          before do
            shell_out_run_success command: "workspace new kitchen-terraform-test-suite-test-platform"
          end

          it_behaves_like "terraform: get; validate; apply"
        end
      end

      context "when `terraform workspace select <kitchen-instance>` results in success" do
        before do
          shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
        end

        it_behaves_like "terraform: get; validate; apply"
      end
    end

    it_behaves_like "the action fails if the Terraform version is unsupported" do
      let :action do
        subject.apply
      end
    end

    context "when the Terraform version is unsupported but verification is disabled" do
      let :verify_version do
        false
      end

      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive(:call).and_raise ::Kitchen::Terraform::Error
      end

      it_behaves_like "it selects the instance workspace and generates the state"
    end

    context "when the Terraform version is supported" do
      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive :call
      end

      it_behaves_like "it selects the instance workspace and generates the state"
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
      it_behaves_like "the action fails if the Terraform root module can not be initialized" do
        let :action do
          subject.create({})
        end
      end

      context "when `terraform init` results in success" do
        before do
          shell_out_run_success(
            command: "init " \
            "-input=false " \
            "-lock=true " \
            "-lock-timeout=0s " \
            "-no-color " \
            "-upgrade " \
            "-force-copy " \
            "-backend=true " \
            "-backend-config=\"string=\\\"A String\\\"\" " \
            "-backend-config=\"map={ key = \\\"A Value\\\" }\" " \
            "-backend-config=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
            "-get=true " \
            "-get-plugins=true " \
            "-plugin-dir=\"#{plugin_directory}\" " \
            "-verify-plugins=true",
          )
        end

        it_behaves_like "the action fails if the Terraform workspace can not be selected or created" do
          let :action do
            subject.create({})
          end
        end

        context "when `terraform workspace select <kitchen-instance>` results in failure" do
          before do
            shell_out_run_failure(
              command: "workspace select kitchen-terraform-test-suite-test-platform",
              message: "mocked `terraform workspace select <kitchen-instance>` failure",
            )
          end

          context "when `terraform workspace new <kitchen-instance>` results in success" do
            before do
              shell_out_run_success command: "workspace new kitchen-terraform-test-suite-test-platform"
            end

            specify "should result in success" do
              expect do
                subject.create({})
              end.not_to raise_error
            end
          end
        end

        context "when `terraform workspace select <kitchen-instance>` results in success" do
          before do
            shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
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
      let :verify_version do
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

    let :plugin_directory do
      nil
    end

    before do
      described_instance.finalize_config! kitchen_instance
    end

    shared_examples "it destroys the state" do
      let :action do
        subject.destroy({})
      end

      context "when `terraform destroy` results in failure" do
        before do
          shell_out_run_failure command: /destroy/, message: "mocked `terraform destroy` failure"
        end

        specify "should result in an action failed error with the failed command output" do
          expect do
            action
          end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform destroy` failure"
        end
      end

      context "when `terraform destroy` results in success" do
        before do
          shell_out_run_success(
            command: "destroy " \
            "-auto-approve " \
            "-lock=true " \
            "-lock-timeout=0s " \
            "-input=false " \
            "-no-color " \
            "-parallelism=10 " \
            "-refresh=true " \
            "-var=\"string=\\\"A String\\\"\" " \
            "-var=\"map={ key = \\\"A Value\\\" }\" " \
            "-var=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
            "-var-file=\"/Arbitrary Directory/Variable File.tfvars\"",
          )
        end

        context "when `terraform select default` results in failure" do
          before do
            shell_out_run_failure(
              command: "workspace select default",
              message: "mocked `terraform workspace select default` failure",
            )
          end

          specify "should result in an action failed error with the failed command output" do
            expect do
              action
            end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform workspace select default` failure"
          end
        end

        context "when `terraform workspace select default` results in success" do
          before do
            shell_out_run_success command: "workspace select default"
          end

          context "when `terraform workspace delete <kitchen-instance>` results in failure" do
            before do
              shell_out_run_failure(
                command: "workspace delete kitchen-terraform-test-suite-test-platform",
                message: "mocked `terraform workspace delete <kitchen-instance>` failure",
              )
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
              shell_out_run_success command: "workspace delete kitchen-terraform-test-suite-test-platform"
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

    shared_examples "it initializes the root module, selects the instance workspace, and destroys the state" do
      it_behaves_like "the action fails if the Terraform root module can not be initialized" do
        let :action do
          subject.destroy({})
        end
      end

      context "when `terraform init` results in success" do
        before do
          shell_out_run_success(
            command: "init " \
            "-input=false " \
            "-lock=true " \
            "-lock-timeout=0s " \
            "-no-color " \
            "-force-copy " \
            "-backend=true " \
            "-backend-config=\"string=\\\"A String\\\"\" " \
            "-backend-config=\"map={ key = \\\"A Value\\\" }\" " \
            "-backend-config=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
            "-get=true " \
            "-get-plugins=true " \
            "-verify-plugins=true",
          )
        end

        it_behaves_like "the action fails if the Terraform workspace can not be selected or created" do
          let :action do
            subject.destroy({})
          end
        end

        context "when the Terraform workspace is created" do
          before do
            shell_out_run_failure(
              command: "workspace select kitchen-terraform-test-suite-test-platform",
              message: "mocked `terraform workspace select <kitchen-instance>` failure",
            )
            shell_out_run_success command: "workspace new kitchen-terraform-test-suite-test-platform"
          end

          it_behaves_like "it destroys the state"
        end

        context "when `terraform workspace select <kitchen-instance>` results in success" do
          before do
            shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
          end

          it_behaves_like "it destroys the state"
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
      let :verify_version do
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

    shared_examples "`terraform output` is run" do
      context "when the command results in failure due to no outputs defined" do
        before do
          shell_out_run_failure command: "output -json", message: "no outputs defined"
        end

        specify "should ignore the failure and yield an empty hash" do
          expect do |block|
            subject.retrieve_outputs(&block)
          end.to yield_with_args outputs: {}
        end
      end

      context "when the command results in failure not due to no outputs defined" do
        before do
          shell_out_run_failure command: "output -json", message: "mocked `terraform output` failure"
        end

        specify "should result in an action failed error with the failed command output" do
          expect do
            subject.retrieve_outputs
          end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform output` failure"
        end
      end

      context "when the command results in success" do
        before do
          shell_out_run_yield command: "output -json", standard_output: terraform_output_value
        end

        context "when the value of the command result is not valid JSON" do
          let :terraform_output_value do
            "not valid JSON"
          end

          specify "should result in an action failed error with a message indicating the output is not valid JSON" do
            expect do
              subject.retrieve_outputs
            end.to raise_error ::Kitchen::ActionFailed, /Parsing Terraform output as JSON failed:/
          end
        end

        context "when the value of the command result is valid JSON" do
          let :terraform_output_value do
            ::JSON.dump value_as_hash
          end

          let :value_as_hash do
            {output_name: {sensitive: false, type: "list", value: ["output_value_1"]}}
          end

          specify "should yield the hash which results from processing the output as JSON" do
            expect do |block|
              subject.retrieve_outputs(&block)
            end.to yield_with_args(
              outputs: {
                "output_name" => {"sensitive" => false, "type" => "list", "value" => ["output_value_1"]},
              },
            )
          end
        end
      end
    end

    it_behaves_like "the action fails if the Terraform workspace can not be selected or created" do
      let :action do
        subject.retrieve_outputs
      end
    end

    context "when `terraform workspace select <kitchen-instance>` results in failure" do
      before do
        shell_out_run_failure(
          command: "workspace select kitchen-terraform-test-suite-test-platform",
          message: "mocked `terraform workspace select <kitchen-instance>` failure",
        )
      end

      context "when `terraform workspace new <kitchen-instance>` results in success" do
        before do
          shell_out_run_success command: "workspace new kitchen-terraform-test-suite-test-platform"
        end

        it_behaves_like "`terraform output` is run"
      end
    end

    context "when `terraform workspace select <kitchen-instance>` results in success" do
      before do
        shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
      end

      it_behaves_like "`terraform output` is run"
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
