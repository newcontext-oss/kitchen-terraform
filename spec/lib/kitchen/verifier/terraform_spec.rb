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

require "inspec"
require "kitchen"
require "kitchen/driver/terraform"
require "kitchen/terraform/inspec_options_factory"
require "kitchen/terraform/variables_manager"
require "kitchen/terraform/outputs_manager"
require "kitchen/transport/ssh"
require "kitchen/verifier/terraform"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/fail_fast_examples"
require "support/kitchen/terraform/config_attribute/systems_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Verifier::Terraform do
  subject do
    described_class.new config
  end

  let :config do
    {
      color: false,
      fail_fast: config_fail_fast,
      systems: [
        {
          attrs_outputs: { attribute_name: "output_name" },
          attrs: ["attrs.yml"],
          backend: "backend",
          backend_cache: false,
          bastion_host: "bastion_host",
          bastion_port: 5678,
          bastion_user: "bastion_user",
          controls: ["control"],
          enable_password: "enable_password",
          hosts_output: "hosts",
          key_files: ["first_key_file", "second_key_file"],
          name: "a-system-with-hosts",
          password: "password",
          path: "path",
          port: 1234,
          proxy_command: "proxy_command",
          reporter: ["reporter"],
          self_signed: false,
          shell: false,
          shell_command: "/bin/shell",
          shell_options: "--option=value",
          sudo: false,
          sudo_command: "/bin/sudo",
          sudo_options: "--option=value",
          sudo_password: "sudo_password",
          show_progress: false,
          ssl: false,
          user: "user",
          vendor_cache: "vendor_cache",
        },
        {
          name: "a-system-without-hosts",
          attrs_outputs: { attribute_name: "output_name" },
          backend: "backend",
          profile_locations: ["remote://profile"],
        },
      ],
      test_base_path: "/test/base/path",
    }
  end

  let :config_fail_fast do
    true
  end

  let :driver do
    instance_double ::Kitchen::Driver::Terraform
  end

  let :kitchen_instance do
    instance_double ::Kitchen::Instance
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :transport do
    ::Kitchen::Transport::Ssh.new
  end

  before do
    allow(kitchen_instance).to receive(:logger).and_return logger
    allow(kitchen_instance).to receive(:transport).and_return transport
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"
  it_behaves_like "Kitchen::Terraform::ConfigAttribute::FailFast"
  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Systems"

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#call" do
    let :kitchen_instance_state do
      {}
    end

    let :kitchen_suite do
      instance_double ::Kitchen::Suite
    end

    before do
      allow(kitchen_instance).to receive(:driver).and_return driver
      allow(kitchen_instance).to receive(:suite).and_return kitchen_suite
      allow(kitchen_suite).to receive(:name).and_return "test-suite"
      subject.finalize_config! kitchen_instance
    end

    context "when the Terraform output mapped to the :hosts key is in an unexpected format" do
      before do
        ::Kitchen::Terraform::VariablesManager.new(logger: logger).save(
          variables: { variable: "input value" },
          state: kitchen_instance_state,
        )
        ::Kitchen::Terraform::OutputsManager.new(logger: logger).save(
          outputs: { hosts: { amount: "host" }, output_name: { amount: "output value" } },
          state: kitchen_instance_state,
        )
      end

      specify "should raise an action failed error" do
        expect do
          subject.call kitchen_instance_state
        end.to raise_error ::Kitchen::ActionFailed, "Failed verification of the 'a-system-with-hosts' system."
      end
    end

    context "when the Terraform outputs omit a key from the values of the :attrs_outputs key" do
      before do
        ::Kitchen::Terraform::VariablesManager.new(logger: logger).save(
          variables: { variable: "input value" },
          state: kitchen_instance_state,
        )
        ::Kitchen::Terraform::OutputsManager.new(logger: logger).save(
          outputs: { hosts: { value: "host" } },
          state: kitchen_instance_state,
        )
      end

      specify "should raise an action failed error" do
        expect do
          subject.call kitchen_instance_state
        end.to raise_error ::Kitchen::ActionFailed, "Failed verification of the 'a-system-with-hosts' system."
      end
    end

    context "when a Terraform output mapped to a :attrs_outputs key is in an unexpected format" do
      before do
        ::Kitchen::Terraform::VariablesManager.new(logger: logger).save(
          variables: { variable: "input value" },
          state: kitchen_instance_state,
        )
        ::Kitchen::Terraform::OutputsManager.new(logger: logger).save(
          outputs: { hosts: { value: "host" }, output_name: { amount: "output value" } },
          state: kitchen_instance_state,
        )
      end

      specify "should raise an action failed error" do
        expect do
          subject.call kitchen_instance_state
        end.to raise_error ::Kitchen::ActionFailed, "Failed verification of the 'a-system-with-hosts' system."
      end
    end

    context "when the Terraform outputs omits the value of the :hosts_output key" do
      before do
        ::Kitchen::Terraform::VariablesManager.new(logger: logger).save(
          variables: { variable: "input value" },
          state: kitchen_instance_state,
        )
        ::Kitchen::Terraform::OutputsManager.new(logger: logger).save(
          outputs: { output_name: { value: "output value" } },
          state: kitchen_instance_state,
        )
      end

      specify "should raise an action failed error" do
        expect do
          subject.call kitchen_instance_state
        end.to raise_error ::Kitchen::ActionFailed, "Failed verification of the 'a-system-with-hosts' system."
      end
    end

    context "when the Terraform outputs are correctly formatted and match the configuration" do
      let :runner do
        instance_double(::Inspec::Runner).tap do |runner|
          allow(runner).to receive(:add_target).with "/test/base/path/test-suite"
          allow(runner).to receive(:add_target).with "remote://profile"
        end
      end

      let :runner_options_with_hosts do
        {
          "color" => false,
          "distinct_exit" => false,
          "reporter" => ["reporter"],
          backend_cache: false,
          backend: "backend",
          bastion_host: "bastion_host",
          bastion_port: 5678,
          bastion_user: "bastion_user",
          controls: ["control"],
          enable_password: "enable_password",
          host: "host",
          input_file: ["attrs.yml"],
          ::Kitchen::Terraform::InSpecOptionsFactory.inputs_key => {
            "attribute_name" => "output value",
            "hosts" => "host",
            "input_variable" => "input value",
            "output_hosts" => "host",
            "output_name" => "output value",
            "output_output_name" => "output value",
          },
          key_files: ["first_key_file", "second_key_file"],
          logger: logger,
          password: "password",
          path: "path",
          port: 1234,
          proxy_command: "proxy_command",
          self_signed: false,
          shell_command: "/bin/shell",
          shell_options: "--option=value",
          shell: false,
          show_progress: false,
          ssl: false,
          sudo_command: "/bin/sudo",
          sudo_options: "--option=value",
          sudo_password: "sudo_password",
          sudo: false,
          user: "user",
          vendor_cache: "vendor_cache",
        }
      end

      let :runner_options_without_hosts do
        {
          "color" => false,
          "distinct_exit" => false,
          backend: "backend",
          ::Kitchen::Terraform::InSpecOptionsFactory.inputs_key => {
            "attribute_name" => "output value",
            "hosts" => "host",
            "input_variable" => "input value",
            "output_hosts" => "host",
            "output_name" => "output value",
            "output_output_name" => "output value",
          },
          logger: logger,
        }
      end

      before do
        ::Kitchen::Terraform::VariablesManager.new(logger: logger).save(
          variables: { variable: "input value" },
          state: kitchen_instance_state,
        )
        ::Kitchen::Terraform::OutputsManager.new(logger: logger).save(
          outputs: { hosts: { value: "host" }, output_name: { value: "output value" } },
          state: kitchen_instance_state,
        )
        allow(::Inspec::Runner).to receive(:new).with(runner_options_with_hosts).and_return(runner)
        allow(::Inspec::Runner).to receive(:new).with(runner_options_without_hosts).and_return(runner)
      end

      context "when fail fast behaviour is enabled" do
        context "when the InSpec runner returns an exit code other than 0" do
          before do
            allow(runner).to receive(:run).with(no_args).and_return(1)
          end

          it "does raise an error" do
            expect do
              subject.call kitchen_instance_state
            end.to raise_error ::Kitchen::ActionFailed, "Failed verification of the 'a-system-with-hosts' system."
          end
        end

        context "when the InSpec runner raises an error" do
          before do
            allow(runner).to receive(:run).with(no_args).and_raise ::Train::UserError, "mocked InSpec error"
          end

          specify "should raise an action failed error" do
            expect do
              subject.call kitchen_instance_state
            end.to raise_error ::Kitchen::ActionFailed, "Failed verification of the 'a-system-with-hosts' system."
          end
        end
      end

      context "when fail fast behaviour is disabled" do
        let :config_fail_fast do
          false
        end

        context "when the InSpec runner returns an exit code other than 0 multiple times" do
          before do
            allow(runner).to receive(:run).with(no_args).and_return 1
          end

          specify "should raise an ActionFailed with all error messages" do
            expect do
              subject.call kitchen_instance_state
            end.to raise_error(
              ::Kitchen::ActionFailed,
              "Failed verification of the 'a-system-with-hosts' system.\n\n" \
              "Failed verification of the 'a-system-without-hosts' system."
            )
          end
        end

        context "when the InSpec runner raises an error multiple times" do
          before do
            allow(runner).to receive(:run).with(no_args).and_raise ::Train::UserError, "mocked InSpec error"
          end

          specify "should raise an ActionFailed with all error messages" do
            expect do
              subject.call kitchen_instance_state
            end.to raise_error(
              ::Kitchen::ActionFailed,
              "Failed verification of the 'a-system-with-hosts' system.\n\n" \
              "Failed verification of the 'a-system-without-hosts' system."
            )
          end
        end
      end

      context "when the InSpec runner returns an exit code of 0" do
        before do
          allow(runner).to receive(:run).with(no_args).and_return 0
        end

        it "does not raise an error" do
          expect do
            subject.call kitchen_instance_state
          end.to_not raise_error
        end
      end
    end
  end

  describe "#doctor" do
    let :kitchen_instance_state do
      {}
    end

    specify "should return false" do
      expect(subject.doctor(kitchen_instance_state)).to be_falsey
    end
  end

  describe "#load_needed_dependencies!" do
    context "when the inspec gem is not available" do
      let :error_message do
        "mocked LoadError"
      end

      before do
        allow(subject).to receive(:require).with("kitchen/terraform/inspec_runner").and_raise ::LoadError, error_message
      end

      specify "should raise a client error" do
        expect do
          subject.finalize_config! kitchen_instance
        end.to raise_error ::Kitchen::ClientError, error_message
      end
    end
  end
end
