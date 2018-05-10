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
          logger: instance_double(::Object),
          root_module_directory: "/root/module/directory",
          timeout: 123,
          workspace_name: "workspace-name"
        )
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
              timeout: 123
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

    shared_examples "a command with ignored output" do |command:|
      let :flags do
        [
          "-flag-without-value",
          "-flag-with-value=\"value\""
        ]
      end

      let :full_command do
        "#{command} #{flags.first} #{flags.last} /root/module/directory"
      end

      let :method do
        command
      end

      def expect_invoking_method
        expect do
          subject
            .send(
              method,
              flags: flags
            )
        end
      end

      it_behaves_like "a command with ignored output when it fails"
      it_behaves_like "a command with ignored output when it succeeds"
    end

    shared_examples "a command with ignored output when it fails" do
      before do
        fail_run_terraform command: full_command
      end

      specify do
        expect_invoking_method.to raise_shell_command_failed
      end
    end

    shared_examples "a command with ignored output when it succeeds" do
      before do
        succeed_run_terraform command: full_command
      end

      specify do
        expect_invoking_method.to_not raise_shell_command_failed
      end
    end

    describe "#apply" do
      it_behaves_like(
        "a command with ignored output",
        command: :apply
      )
    end

    describe "#delete_kitchen_instance_workspace" do
      def expect_invoking_method
        expect do
          subject.delete_kitchen_instance_workspace
        end
      end

      context "when `terraform workspace delete` fails" do
        before do
          fail_run_terraform command: "workspace delete kitchen-terraform-workspace-name"
        end

        specify do
          expect_invoking_method.to raise_shell_command_failed
        end
      end

      context "when `terraform workspace delete` succeeds" do
        before do
          succeed_run_terraform command: "workspace delete kitchen-terraform-workspace-name"
        end

        specify do
          expect_invoking_method.to_not raise_shell_command_failed
        end
      end
    end

    describe "#destroy" do
      it_behaves_like(
        "a command with ignored output",
        command: :destroy
      )
    end

    describe "#get" do
      it_behaves_like(
        "a command with ignored output",
        command: :get
      )
    end

    describe "#init" do
      it_behaves_like(
        "a command with ignored output",
        command: :init
      )
    end

    describe "#if_version_not_supported" do
      def expect_invoking_method
        expect do |block|
          subject.if_version_not_supported &block
        end
      end

      context "when `terraform version` fails" do
        before do
          fail_run_terraform command: "version"
        end

        specify do
          expect_invoking_method.to raise_shell_command_failed
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
          expect_invoking_method.to yield_with_args message: /< 0.12.0, >= 0.10.2/
        end
      end

      context "when `terraform version` succeeds and the version is equal to 0.10.2" do
        before do
          succeed_run_version output: "0.10.2"
        end

        specify do
          expect_invoking_method.to_not yield_control
        end
      end

      context "when `terraform version` succeeds and the version is greater than 0.10.2 and less than 0.12.0" do
        before do
          succeed_run_version output: "0.11.9"
        end

        specify do
          expect_invoking_method.to_not yield_control
        end
      end

      context "when `terraform version` succeeds and the version is equal to 0.12.0" do
        before do
          succeed_run_version output: "0.12.0"
        end

        specify do
          expect_invoking_method.to yield_with_args message: /< 0.12.0, >= 0.10.2/
        end
      end
    end

    describe "#validate" do
      it_behaves_like(
        "a command with ignored output",
        command: :validate
      )
    end

    describe "#within_kitchen_instance_workspace" do
      def expect_invoking_method
        expect do |block|
          subject.within_kitchen_instance_workspace &block
        end
      end

      shared_examples "it yields control and selects the default workspace" do
        context "when `terraform workspace select default` fails" do
          before do
            fail_run_terraform command: "workspace select default"
          end

          specify do
            expect_invoking_method.to yield_control.and raise_shell_command_failed
          end
        end

        context "when `terraform workspace select default` succeeds" do
          before do
            succeed_run_terraform command: "workspace select default"
          end

          specify do
            expect_invoking_method.to yield_control
          end
        end
      end

      context "when `terraform workspace select kitchen-terraform-workspace-name` fails" do
        before do
          fail_run_terraform command: "workspace select kitchen-terraform-workspace-name"
        end

        context "when `terraform workspace new kitchen-terraform-workspace-name` fails" do
          before do
            fail_run_terraform command: "workspace new kitchen-terraform-workspace-name"
          end

          specify do
            expect_invoking_method.to raise_shell_command_failed
          end
        end

        context "when `terraform workspace new kitchen-terraform-workspace-name` succeeds" do
          before do
            succeed_run_terraform command: "workspace new kitchen-terraform-workspace-name"
          end

          it_behaves_like "it yields control and selects the default workspace"
        end
      end

      context "when `terraform workspace select kitchen-terraform-workspace-name` succeeds" do
        before do
          succeed_run_terraform command: "workspace select kitchen-terraform-workspace-name"
        end

        it_behaves_like "it yields control and selects the default workspace"
      end
    end
  end
