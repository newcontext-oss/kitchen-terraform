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
require "kitchen/terraform/client"

::RSpec
  .describe ::Kitchen::Terraform::Client do
    subject do
      described_class
        .new(
          logger: logger,
          root_module_directory: root_module_directory,
          timeout: timeout,
          workspace_name: workspace_name
        )
    end

    let :logger do
      instance_double ::Object
    end

    let :root_module_directory do
      "/root/module/directory"
    end

    let :timeout do
      123
    end

    let :workspace_name do
      "workspace-name"
    end

    def allow_run_terraform(command:)
      allow(subject)
        .to(
          receive(:run_command)
            .with(
              "terraform #{command}",
              environment:
                {
                  "LC_ALL" => nil,
                  "TF_IN_AUTOMATION" => "true"
                },
              timeout: timeout
            )
        )
    end

    def fail_run_terraform(command:)
      allow_run_terraform(command: command)
        .and_raise(
          ::Kitchen::ShellOut::ShellCommandFailed,
          "shell command failed"
        )
    end

    def succeed_run_terraform(command:, output: "Terraform command output")
      allow_run_terraform(command: command).and_return output
    end

    def raise_shell_command_failed
      raise_error(
        ::Kitchen::ShellOut::ShellCommandFailed,
        "shell command failed"
      )
    end

    describe "#apply" do
      context "when `terraform apply` fails" do
        before do
          fail_run_terraform command: "apply -flag /root/module/directory"
        end

        specify do
          expect do
            subject.apply flags: ["-flag"]
          end
            .to raise_shell_command_failed
        end
      end

      context "when `terraform apply` succeeds" do
        before do
          succeed_run_terraform command: "apply -flag /root/module/directory"
        end

        specify do
          expect do
            subject.apply flags: ["-flag"]
          end
            .to_not raise_shell_command_failed
        end
      end
    end

    describe "#delete_kitchen_instance_workspace" do
      context "when `terraform workspace delete` fails" do
        before do
          fail_run_terraform command: "workspace delete kitchen-terraform-workspace-name"
        end

        specify do
          expect do
            subject.delete_kitchen_instance_workspace
          end
            .to raise_shell_command_failed
        end
      end

      context "when `terraform workspace delete` succeeds" do
        before do
          succeed_run_terraform command: "workspace delete kitchen-terraform-workspace-name"
        end

        specify do
          expect do
            subject.delete_kitchen_instance_workspace
          end
            .to_not raise_shell_command_failed
        end
      end
    end

    describe "#destroy" do
      context "when `terraform destroy` fails" do
        before do
          fail_run_terraform command: "destroy -flag /root/module/directory"
        end

        specify do
          expect do
            subject.destroy flags: ["-flag"]
          end
            .to raise_shell_command_failed
        end
      end

      context "when `terraform destroy` succeeds" do
        before do
          succeed_run_terraform command: "destroy -flag /root/module/directory"
        end

        specify do
          expect do
            subject.destroy flags: ["-flag"]
          end
            .to_not raise_shell_command_failed
        end
      end
    end

    describe "#get" do
      context "when `terraform get` fails" do
        before do
          fail_run_terraform command: "get -flag /root/module/directory"
        end

        specify do
          expect do
            subject.get flags: ["-flag"]
          end
            .to raise_shell_command_failed
        end
      end

      context "when `terraform get` succeeds" do
        before do
          succeed_run_terraform command: "get -flag /root/module/directory"
        end

        specify do
          expect do
            subject.get flags: ["-flag"]
          end
            .to_not raise_shell_command_failed
        end
      end
    end

    describe "#init" do
      context "when `terraform init` fails" do
        before do
          fail_run_terraform command: "init -flag /root/module/directory"
        end

        specify do
          expect do
            subject.init flags: ["-flag"]
          end
            .to raise_shell_command_failed
        end
      end

      context "when `terraform init` succeeds" do
        before do
          succeed_run_terraform command: "init -flag /root/module/directory"
        end

        specify do
          expect do
            subject.init flags: ["-flag"]
          end
            .to_not raise_shell_command_failed
        end
      end
    end

    describe "#if_version_not_supported" do
      context "when `terraform version` fails" do
        before do
          fail_run_terraform command: "version"
        end

        specify do
          expect do
            subject.if_version_not_supported
          end
            .to raise_shell_command_failed
        end
      end

      def succeed_run_version(output:)
        succeed_run_terraform(
          command: "version",
          output: output
        )
      end

      context "when `terraform version` succeeds and the version is less than 0.10.2" do
        before do
          succeed_run_version output: "0.10.1"
        end

        specify do
          expect do |block|
            subject.if_version_not_supported &block
          end
            .to yield_with_args message: /< 0.12.0, >= 0.10.2/
        end
      end

      context "when `terraform version` succeeds and the version is equal to 0.10.2" do
        before do
          succeed_run_version output: "0.10.2"
        end

        specify do
          expect do |block|
            subject.if_version_not_supported &block
          end
            .to_not yield_control
        end
      end

      context "when `terraform version` succeeds and the version is greater than 0.10.2 and less than 0.12.0" do
        before do
          succeed_run_version output: "0.11.9"
        end

        specify do
          expect do |block|
            subject.if_version_not_supported &block
          end
            .to_not yield_control
        end
      end

      context "when `terraform version` succeeds and the version is equal to 0.12.0" do
        before do
          succeed_run_version output: "0.12.0"
        end

        specify do
          expect do |block|
            subject.if_version_not_supported &block
          end
            .to yield_with_args message: /< 0.12.0, >= 0.10.2/
        end
      end
    end

    describe "#validate" do
      context "when `terraform validate` fails" do
        before do
          fail_run_terraform command: "validate -flag /root/module/directory"
        end

        specify do
          expect do
            subject.validate flags: ["-flag"]
          end
            .to raise_shell_command_failed
        end
      end

      context "when `terraform validate` succeeds" do
        before do
          succeed_run_terraform command: "validate -flag /root/module/directory"
        end

        specify do
          expect do
            subject.validate flags: ["-flag"]
          end
            .to_not raise_shell_command_failed
        end
      end
    end

    describe "#within_kitchen_instance_workspace" do
      context "when `terraform workspace select kitchen-terraform-workspace-name` fails" do
        before do
          fail_run_terraform command: "workspace select kitchen-terraform-workspace-name"
        end

        context "when `terraform workspace new kitchen-terraform-workspace-name` fails" do
          before do
            fail_run_terraform command: "workspace new kitchen-terraform-workspace-name"
          end

          specify do
            expect do
              subject.within_kitchen_instance_workspace
            end
              .to raise_shell_command_failed
          end
        end

        context "when `terraform workspace new kitchen-terraform-workspace-name` succeeds" do
          before do
            succeed_run_terraform command: "workspace new kitchen-terraform-workspace-name"
          end

          context "when `terraform workspace select default` fails" do
            before do
              fail_run_terraform command: "workspace select default"
            end

            specify do
              expect do |block|
                begin
                  subject.within_kitchen_instance_workspace &block
                rescue ::Kitchen::ShellOut::ShellCommandFailed
                end
              end
                .to yield_control
            end

            specify do
              expect do
                subject
                  .within_kitchen_instance_workspace do
                  end
              end
                .to raise_shell_command_failed
            end
          end

          context "when `terraform workspace select default` succeeds" do
            before do
              succeed_run_terraform command: "workspace select default"
            end

            specify do
              expect do |block|
                subject.within_kitchen_instance_workspace &block
              end
                .to yield_control
            end

            specify do
              expect do
                subject
                  .within_kitchen_instance_workspace do
                  end
              end
                .to_not raise_shell_command_failed
            end
          end
        end
      end

      context "when `terraform workspace select kitchen-terraform-workspace-name` succeeds" do
        before do
          succeed_run_terraform command: "workspace select kitchen-terraform-workspace-name"
        end

        context "when `terraform workspace select default` fails" do
          before do
            fail_run_terraform command: "workspace select default"
          end

          specify do
            expect do |block|
              begin
                subject.within_kitchen_instance_workspace &block
              rescue ::Kitchen::ShellOut::ShellCommandFailed
              end
            end
              .to yield_control
          end

          specify do
            expect do
              subject
                .within_kitchen_instance_workspace do
                end
            end
              .to raise_shell_command_failed
          end
        end

        context "when `terraform workspace select default` succeeds" do
          before do
            succeed_run_terraform command: "workspace select default"
          end

          specify do
            expect do |block|
              subject.within_kitchen_instance_workspace &block
            end
              .to yield_control
          end

          specify do
            expect do
              subject
                .within_kitchen_instance_workspace do
                end
            end
              .to_not raise_shell_command_failed
          end
        end
      end
    end
  end
