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

require "json"
require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/terraform/command_executor"
require "kitchen/terraform/command/version"
require "kitchen/terraform/debug_logger"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/driver/destroy"
require "kitchen/terraform/verify_version"
require "pathname"
require "rubygems"
require "support/kitchen/terraform/config_attribute/backend_configurations_examples"
require "support/kitchen/terraform/config_attribute/client_examples"
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

::RSpec.describe ::Kitchen::Driver::Terraform do
  subject do
    described_class.new config
  end

  let :command_timeout do
    1234
  end

  let :config do
    {
      backend_configurations: {
        string: "\\\"A String\\\"", map: "{ key = \\\"A Value\\\" }",
        list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
      },
      client: config_client,
      color: false,
      command_timeout: command_timeout,
      kitchen_root: kitchen_root,
      plugin_directory: plugin_directory,
      variable_files: ["/Arbitrary Directory/Variable File.tfvars"],
      variables: config_variables,
      verify_version: verify_version,
    }
  end

  let :config_client do
    allow(::TTY::Which).to receive(:exist?).with("client").and_return true

    "client"
  end

  let :config_variables do
    {
      string: "\\\"A String\\\"",
      map: "{ key = \\\"A Value\\\" }",
      list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
    }
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new driver: subject, lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
                            logger: kitchen_logger, platform: ::Kitchen::Platform.new(name: "test-platform"),
                            provisioner: ::Kitchen::Provisioner::Base.new,
                            state_file: ::Kitchen::StateFile.new(kitchen_root, "test-suite-test-platform"),
                            suite: ::Kitchen::Suite.new(name: "test-suite"), transport: ::Kitchen::Transport::Base.new,
                            verifier: ::Kitchen::Verifier::Base.new
  end

  let :kitchen_logger do
    subject.send :logger
  end

  let :kitchen_root do
    "/kitchen/root"
  end

  let :kitchen_state do
    {}
  end

  let :plugin_directory do
    "/Arbitrary Directory/Plugin Directory"
  end

  let :shell_out do
    instance_double ::Kitchen::Terraform::CommandExecutor
  end

  let :verify_version do
    true
  end

  let :version_requirement do
    ::Gem::Requirement.new ">= 0.11.4", "< 0.13.0"
  end

  let :workspace_name do
    "kitchen-terraform-test-suite-test-platform"
  end

  before do
    allow(::Kitchen::Terraform::CommandExecutor).to receive(:new).with(
      client: config_client,
      logger: kitchen_logger,
    ).and_return shell_out
  end

  shared_examples "the action fails if the Terraform root module can not be initialized" do
    let :verify_version_instance do
      instance_double ::Kitchen::Terraform::VerifyVersion
    end

    before do
      allow(::Kitchen::Terraform::VerifyVersion).to receive(:new).with(
        config: config,
        logger: kitchen_logger,
        version_requirement: version_requirement,
      ).and_return verify_version_instance
      allow(verify_version_instance).to receive :call
      shell_out_run_failure command: /init/, message: "mocked `terraform init` failure"
    end

    specify "should result in an action failed error with the failed command output" do
      expect do
        action
      end.to raise_error ::Kitchen::ActionFailed, "mocked `terraform init` failure"
    end
  end

  shared_examples "the action fails if the Terraform workspace can not be selected or created" do
    let :verify_version_instance do
      instance_double ::Kitchen::Terraform::VerifyVersion
    end

    before do
      allow(::Kitchen::Terraform::VerifyVersion).to receive(:new).with(
        config: config,
        logger: kitchen_logger,
        version_requirement: version_requirement,
      ).and_return verify_version_instance
      allow(verify_version_instance).to receive :call
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
    allow(shell_out).to receive(:run).with(
      command: command,
      options: { cwd: working_directory, timeout: command_timeout },
    ).and_raise ::Kitchen::TransientFailure, message
  end

  def shell_out_run_success(command:, return_value: "mocked `terraform` success", working_directory: kitchen_root)
    allow(shell_out).to receive(:run).with(
      command: command,
      options: { cwd: working_directory, timeout: command_timeout },
    ).and_return return_value
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::BackendConfigurations"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Client"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::CommandTimeout"

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
    before do
      subject.finalize_config! kitchen_instance
    end

    shared_examples "Terraform: get; validate; apply; output" do
      let :verify_version_instance do
        instance_double ::Kitchen::Terraform::VerifyVersion
      end

      before do
        allow(::Kitchen::Terraform::VerifyVersion).to receive(:new).with(
          config: config,
          logger: kitchen_logger,
          version_requirement: version_requirement,
        ).and_return verify_version_instance
        allow(verify_version_instance).to receive :call
      end

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
            let :debug_shell_out do
              instance_double ::Kitchen::Terraform::CommandExecutor
            end

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
              allow(::Kitchen::Terraform::CommandExecutor).to receive(:new).with(client: config_client, logger: kind_of(::Kitchen::Terraform::DebugLogger)).and_return debug_shell_out
            end

            context "when `terraform output` results in failure due to no outputs defined" do
              before do
                allow(debug_shell_out).to receive(:run).with(
                  command: "output -json",
                  options: { cwd: kitchen_root, timeout: command_timeout },
                ).and_raise ::Kitchen::TransientFailure, "no outputs defined"
              end

              specify "should ignore the failure and yield an empty hash" do
                expect do |block|
                  subject.apply(&block)
                end.to yield_with_args outputs: {}
              end
            end

            context "when `terraform output` results in failure not due to no outputs defined" do
              let :error_message do
                "mocked `terraform output` failure"
              end

              before do
                allow(debug_shell_out).to receive(:run).with(
                  command: "output -json",
                  options: { cwd: kitchen_root, timeout: command_timeout },
                ).and_raise ::Kitchen::TransientFailure, error_message
              end

              specify "should result in an action failed error with the failed command output" do
                expect do
                  subject.apply
                end.to raise_error ::Kitchen::ActionFailed, error_message
              end
            end

            context "when `terraform output` results in success" do
              before do
                allow(debug_shell_out).to receive(:run).with(
                  command: "output -json",
                  options: { cwd: kitchen_root, timeout: command_timeout },
                ).and_yield standard_output: terraform_output_value
              end

              context "when the value of `terraform output` is not valid JSON" do
                let :terraform_output_value do
                  "not valid JSON"
                end

                specify "should result in an action failed error with a message indicating the output is not valid JSON" do
                  expect do
                    subject.apply
                  end.to raise_error ::Kitchen::ActionFailed, /Failed parsing Terraform output as JSON./
                end
              end

              context "when the value of `terraform output` is valid JSON" do
                let :terraform_output_value do
                  ::JSON.dump value_as_hash
                end

                let :value_as_hash do
                  { output_name: { sensitive: false, type: "list", value: ["output_value_1"] } }
                end

                specify "should yield the hash which results from processing the output as JSON" do
                  expect do |block|
                    subject.apply(&block)
                  end.to yield_with_args(
                    outputs: {
                      "output_name" => { "sensitive" => false, "type" => "list", "value" => ["output_value_1"] },
                    },
                  )
                end
              end
            end
          end
        end
      end
    end

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

        it_behaves_like "Terraform: get; validate; apply; output"
      end
    end

    context "when `terraform workspace select <kitchen-instance>` results in success" do
      before do
        shell_out_run_success command: "workspace select kitchen-terraform-test-suite-test-platform"
      end

      it_behaves_like "Terraform: get; validate; apply; output"
    end
  end

  describe "#create" do
    let :create do
      instance_double ::Kitchen::Terraform::Driver::Create
    end

    before do
      allow(::Kitchen::Terraform::Driver::Create).to(
        receive(:new).with(
          config: config,
          logger: kitchen_logger,
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        ).and_return(create)
      )
      subject.finalize_config! kitchen_instance
    end

    specify "should invoke the create strategy" do
      expect(create).to receive :call
    end

    after do
      subject.create kitchen_state
    end
  end

  describe "#destroy" do
    let :destroy do
      instance_double ::Kitchen::Terraform::Driver::Destroy
    end

    before do
      allow(::Kitchen::Terraform::Driver::Destroy).to(
        receive(:new).with(
          config: config,
          logger: kitchen_logger,
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        ).and_return(destroy)
      )
      subject.finalize_config! kitchen_instance
    end

    specify "should invoke the destroy strategy" do
      expect(destroy).to receive :call
    end

    after do
      subject.destroy kitchen_state
    end
  end

  describe "#retrieve_variables" do
    before do
      subject.finalize_config! kitchen_instance
    end

    specify "should yield the variables config attribute" do
      expect do |block|
        subject.retrieve_variables(&block)
      end.to yield_with_args variables: config_variables
    end
  end
end
