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
require "support/kitchen/terraform/config_attribute/systems_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Verifier::Terraform do
  let :config do
    {color: false,
     systems: [{attrs_outputs: {attribute_name: "output_name"}, attrs: ["attrs.yml"], backend: "backend",
                backend_cache: false, bastion_host: "bastion_host", bastion_port: 5678, bastion_user: "bastion_user",
                controls: ["control"], enable_password: "enable_password", hosts_output: "hosts",
                key_files: ["first_key_file", "second_key_file"], name: "a-system", password: "password", path: "path",
                port: 1234, proxy_command: "proxy_command", reporter: ["reporter"], self_signed: false, shell: false,
                shell_command: "/bin/shell", shell_options: "--option=value", sudo: false, sudo_command: "/bin/sudo",
                sudo_options: "--option=value", sudo_password: "sudo_password", show_progress: false, ssl: false,
                user: "user", vendor_cache: "vendor_cache"}],
     test_base_path: "/test/base/path"}
  end

  let :described_instance do
    described_class.new config
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Systems"

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#call" do
    subject do
      lambda do
        described_instance.call({})
      end
    end

    let :driver do
      ::Kitchen::Driver::Terraform.new
    end

    let :kitchen_instance do
      ::Kitchen::Instance.new(
        driver: driver,
        lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
        logger: logger,
        platform: ::Kitchen::Platform.new(name: "test-platform"),
        provisioner: ::Kitchen::Provisioner::Base.new,
        state_file: ::Kitchen::StateFile.new("/kitchen/root", "test-suite-test-platform"),
        suite: ::Kitchen::Suite.new(name: "test-suite"),
        transport: ssh_transport,
        verifier: described_instance,
      )
    end

    let :logger do
      ::Kitchen::Logger.new
    end

    let :ssh_transport do
      ::Kitchen::Transport::Ssh.new
    end

    before do
      described_instance.finalize_config! kitchen_instance
    end

    context "when the Terraform outputs omit a key from the values of the :attrs_outputs key" do
      before do
        allow(driver).to receive(:retrieve_outputs).and_yield outputs: {}
      end

      specify "should raise an action failed error indicating the missing output" do
        is_expected.to raise_error(
          ::Kitchen::ActionFailed,
          "Resolving the attrs of system a-system failed\nkey not found: \"output_name\""
        )
      end
    end

    context "when the Terraform outputs omits the value of the :hosts_output key" do
      before do
        allow(driver).to receive(:retrieve_outputs).and_yield outputs: {"output_name": {"value": "output value"}}
      end

      specify "should raise an action failed error indicating the missing :hosts_output key" do
        is_expected.to raise_error(
          ::Kitchen::ActionFailed,
          "Resolving the hosts of system a-system failed\nkey not found: \"hosts\""
        )
      end
    end

    shared_context "Inspec::Profile" do
      let :profile do
        instance_double ::Inspec::Profile
      end

      before do
        allow(profile).to receive(:name).and_return "profile-name"
      end
    end

    shared_context "Inspec::Runner instance" do
      include_context "Inspec::Profile"

      let :runner do
        instance_double ::Inspec::Runner
      end

      before do
        allow(runner).to receive(:add_target).with(path: "/test/base/path/test-suite").and_return([profile])
      end
    end

    shared_context "Inspec::Runner" do
      include_context "Inspec::Runner instance"

      let :runner_options do
        {
          "color" => false,
          "compression" => false,
          "compression_level" => 0,
          "connection_retries" => 5,
          "connection_retry_sleep" => 1,
          "connection_timeout" => 15,
          "distinct_exit" => false,
          "keepalive" => true,
          "keepalive_interval" => 60,
          "max_wait_until_ready" => 600,
          "reporter" => ["reporter"],
          "sudo" => false,
          "sudo_command" => "sudo -E",
          "sudo_options" => "",
          attributes: {"attribute_name" => "output_value", "hosts" => "host", "output_name" => "output_value"},
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

      before do
        allow(::Inspec::Runner).to receive(:new).with(runner_options).and_return(runner)
      end
    end

    context "when the Terraform outputs do include the configured :hosts_output key" do
      include_context "Inspec::Runner"

      before do
        allow(driver).to receive(:retrieve_outputs).and_yield(
          outputs: {"output_name" => {"value" => "output_value"}, "hosts" => {"value" => "host"}},
        )
      end

      context "when the InSpec runner returns an exit code other than 0" do
        before do
          allow(runner).to receive(:run).with(no_args).and_return(1)
        end

        it "does raise an error" do
          is_expected.to raise_error ::Kitchen::ActionFailed, "InSpec Runner exited with 1"
        end
      end

      context "when the InSpec runner returns an exit code of 0" do
        before do
          allow(runner).to receive(:run).with(no_args).and_return 0
        end

        it "does not raise an error" do
          is_expected.to_not raise_error
        end
      end
    end
  end
end
