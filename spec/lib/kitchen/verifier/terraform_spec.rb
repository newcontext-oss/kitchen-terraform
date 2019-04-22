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
require "kitchen/driver/terraform"
require "kitchen/transport/ssh"
require "kitchen/verifier/terraform"
require "support/kitchen/terraform/config_attribute/color_examples"
require "support/kitchen/terraform/config_attribute/fail_fast_examples"
require "support/kitchen/terraform/config_attribute/systems_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Verifier::Terraform do
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

  let :described_instance do
    described_class.new config
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
    subject do
      described_instance
    end

    let :kitchen_suite do
      instance_double ::Kitchen::Suite
    end

    before do
      allow(kitchen_instance).to receive(:driver).and_return driver
      allow(driver).to receive(:retrieve_inputs).and_yield inputs: { "variable" => "input_value" }
      allow(kitchen_instance).to receive(:suite).and_return kitchen_suite
      allow(kitchen_suite).to receive(:name).and_return "test-suite"
      described_instance.finalize_config! kitchen_instance
    end

    context "when the Terraform outputs are in an unexpected format" do
      before do
        allow(driver).to(receive(:retrieve_outputs) do |&block|
          block.call outputs: { "output_name" => { "amount" => "output_value" } }

          driver
        end)
      end

      specify "should raise an action failed error indicating the unexpected format" do
        expect do
          subject.call({})
        end.to raise_error(
          ::Kitchen::ActionFailed,
          "a-system-with-hosts: Preparing to resolve attrs failed\nkey not found: \"value\""
        )
      end
    end

    context "when the Terraform outputs omit a key from the values of the :attrs_outputs key" do
      before do
        allow(driver).to(receive(:retrieve_outputs) do |&block|
          block.call outputs: {}

          driver
        end)
      end

      specify "should raise an action failed error indicating the missing output" do
        expect do
          subject.call({})
        end.to raise_error(
          ::Kitchen::ActionFailed,
          "a-system-with-hosts: Resolving attrs failed\nkey not found: \"output_name\""
        )
      end
    end

    context "when the Terraform outputs omits the value of the :hosts_output key" do
      before do
        allow(driver).to(receive(:retrieve_outputs) do |&block|
          block.call outputs: { "output_name" => { "value" => "output value" } }

          driver
        end)
      end

      specify "should raise an action failed error indicating the missing :hosts_output key" do
        expect do
          subject.call({})
        end.to raise_error(
          ::Kitchen::ActionFailed,
          "a-system-with-hosts: Resolving hosts failed\nkey not found: \"hosts\""
        )
      end
    end

    context "when the Terraform outputs do include the configured :hosts_output key" do
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
          attributes: {
            "attribute_name" => "output_value",
            "hosts" => "host",
            "input_variable" => "input_value",
            "output_hosts" => "host",
            "output_name" => "output_value",
            "output_output_name" => "output_value",
          },
          attrs: ["attrs.yml"],
          backend: "backend",
          backend_cache: false,
          bastion_host: "bastion_host",
          bastion_port: 5678,
          bastion_user: "bastion_user",
          controls: ["control"],
          enable_password: "enable_password",
          host: "host",
          key_files: ["first_key_file", "second_key_file"],
          logger: logger,
          password: "password",
          path: "path",
          proxy_command: "proxy_command",
          port: 1234,
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
        }
      end

      let :runner_options_without_hosts do
        {
          "color" => false,
          "distinct_exit" => false,
          attributes: {
            "hosts" => "host",
            "input_variable" => "input_value",
            "output_hosts" => "host",
            "output_name" => "output_value",
            "output_output_name" => "output_value",
          },
          backend: "backend",
          logger: logger,
        }
      end

      before do
        allow(::Inspec::Runner).to receive(:new).with(runner_options_with_hosts).and_return(runner)
        allow(::Inspec::Runner).to receive(:new).with(runner_options_without_hosts).and_return(runner)
        allow(driver).to(receive(:retrieve_outputs) do |&block|
          block.call outputs: { "output_name" => { "value" => "output_value" }, "hosts" => { "value" => "host" } }

          driver
        end)
      end

      context "when fail fast behaviour is enabled" do
        context "when the InSpec runner returns an exit code other than 0" do
          before do
            allow(runner).to receive(:run).with(no_args).and_return(1)
          end

          it "does raise an error" do
            expect do
              subject.call({})
            end.to raise_error ::Kitchen::ActionFailed, "a-system-with-hosts: InSpec Runner exited with 1"
          end
        end

        context "when the InSpec runner raises an error" do
          let :error_message do
            "mocked InSpec error"
          end

          before do
            allow(runner).to receive(:run).with(no_args).and_raise ::Train::UserError, error_message
          end

          specify "should raise an action failed error with the runner error message" do
            expect do
              subject.call({})
            end.to raise_error ::Kitchen::ActionFailed, "a-system-with-hosts: Executing InSpec failed\n#{error_message}"
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

          it "does raise all errors" do
            expect do
              subject.call({})
            end.to raise_error(
              ::Kitchen::ActionFailed,
              "a-system-with-hosts: InSpec Runner exited with 1\n\na-system-without-hosts: InSpec Runner exited with 1"
            )
          end
        end

        context "when the InSpec runner raises an error multiple times" do
          let :error_message do
            "mocked InSpec error"
          end

          before do
            allow(runner).to receive(:run).with(no_args).and_raise ::Train::UserError, error_message
          end

          specify "should raise an action failed error with the runner error message" do
            expect do
              subject.call({})
            end.to raise_error(
              ::Kitchen::ActionFailed,
              "a-system-with-hosts: Executing InSpec failed\n#{error_message}\n\n" \
              "a-system-without-hosts: Executing InSpec failed\n#{error_message}"
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
            subject.call({})
          end.to_not raise_error
        end
      end
    end
  end

  describe "#doctor" do
    subject do
      described_class.new config
    end

    let :kitchen_instance do
      ::Kitchen::Instance.new(
        driver: ::Kitchen::Driver::Base.new,
        lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
        logger: ::Kitchen::Logger.new,
        platform: ::Kitchen::Platform.new(name: "test-platform"),
        provisioner: ::Kitchen::Provisioner::Base.new,
        state_file: ::Kitchen::StateFile.new("/kitchen", "test-suite-test-platform"),
        suite: ::Kitchen::Suite.new(name: "test-suite"),
        transport: ::Kitchen::Transport::Base.new,
        verifier: subject,
      )
    end

    before do
      subject.finalize_config! kitchen_instance
    end

    context "when the value of the systems attribute is empty" do
      let :config do
        { systems: [] }
      end

      specify "should return true" do
        expect(subject.doctor({})).to be true
      end
    end

    context "when no issues are detected" do
      specify "should return false" do
        expect(subject.doctor({})).to be false
      end
    end
  end

  describe "#load_needed_dependencies!" do
    context "when the inspec gem is not available" do
      let :error_message do
        "mocked LoadError"
      end

      before do
        allow(subject).to receive(:require).with("kitchen/terraform/inspec").and_raise ::LoadError, error_message
      end

      specify "should raise a client error" do
        expect do
          subject.finalize_config! kitchen_instance
        end.to raise_error ::Kitchen::ClientError, error_message
      end
    end
  end
end
