# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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
require "kitchen/terraform/outputs_manager"
require "kitchen/terraform/system"
require "kitchen/terraform/systems_verifier_factory"
require "kitchen/terraform/systems_verifier/fail_fast"
require "kitchen/terraform/variables_manager"
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
      fail_fast: true,
      systems: config_systems,
      test_base_path: "/test/base/path",
    }
  end

  let :config_systems do
    [
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
    ]
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new(
      driver: ::Kitchen::Driver::Base.new,
      lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config, state_file),
      logger: logger,
      platform: ::Kitchen::Platform.new(name: "test-platform"),
      provisioner: ::Kitchen::Provisioner::Base.new,
      state_file: state_file,
      suite: ::Kitchen::Suite.new(name: "test-suite"),
      transport: ::Kitchen::Transport::Base.new,
      verifier: ::Kitchen::Verifier::Base.new,
    )
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :state_file do
    ::Kitchen::StateFile.new("/kitchen", "test-suite-test-platform")
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Color"
  it_behaves_like "Kitchen::Terraform::ConfigAttribute::FailFast"
  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Systems"
  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#call" do
    let :kitchen_instance_state do
      {}
    end

    let :systems_verifier do
      instance_double ::Kitchen::Terraform::SystemsVerifier::FailFast
    end

    let :systems_verifier_factory do
      instance_double ::Kitchen::Terraform::SystemsVerifierFactory
    end

    before do
      ::Kitchen::Terraform::VariablesManager.new.save(
        variables: { variable: "input value" },
        state: kitchen_instance_state,
      )
      ::Kitchen::Terraform::OutputsManager.new.save(
        outputs: { hosts: { value: "host" }, output_name: { value: "output value" } },
        state: kitchen_instance_state,
      )
      allow(::Kitchen::Terraform::SystemsVerifierFactory).to receive(:new).with(fail_fast: true).and_return(
        systems_verifier_factory
      )
      allow(systems_verifier_factory).to receive(:build).with(
        systems: including(kind_of(::Kitchen::Terraform::System)),
      ).and_return systems_verifier
      subject.finalize_config! kitchen_instance
    end

    context "when the systems verifier does raise an error" do
      before do
        allow(systems_verifier).to receive(:verify).with(
          outputs: { hosts: { value: "host" }, output_name: { value: "output value" } },
          variables: { variable: "input value" },
        ).and_raise ::Kitchen::TransientFailure
      end

      specify "should raise an action failed error" do
        expect do
          subject.call kitchen_instance_state
        end.to raise_error ::Kitchen::ActionFailed
      end
    end

    context "when the systems verifier does not raise an error" do
      before do
        allow(systems_verifier).to receive(:verify).with(
          outputs: { hosts: { value: "host" }, output_name: { value: "output value" } },
          variables: { variable: "input value" },
        )
      end

      specify "should not raise an error" do
        expect do
          subject.call kitchen_instance_state
        end.to_not raise_error
      end
    end
  end

  describe "#doctor" do
    let :kitchen_instance_state do
      {}
    end

    before do
      subject.finalize_config! kitchen_instance
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
