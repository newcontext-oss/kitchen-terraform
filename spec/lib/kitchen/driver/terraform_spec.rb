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
require "kitchen/driver/terraform"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/driver/destroy"
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

  let :config do
    { client: "client" }
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new(
      driver: subject,
      lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config, state_file),
      logger: ::Kitchen::Logger.new,
      platform: ::Kitchen::Platform.new(name: "test-platform"),
      provisioner: ::Kitchen::Provisioner::Base.new,
      state_file: state_file,
      suite: ::Kitchen::Suite.new(name: "test-suite"),
      transport: ::Kitchen::Transport::Base.new,
      verifier: ::Kitchen::Verifier::Base.new,
    )
  end

  let :state do
    {}
  end

  let :state_file do
    ::Kitchen::StateFile.new "/kitchen", "test-suite-test-platform"
  end

  let :version_requirement do
    ::Gem::Requirement.new ">= 0.11.4", "< 2.0.0"
  end

  let :workspace_name do
    "kitchen-terraform-test-suite-test-platform"
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
      expect(described_class.serial_actions).to contain_exactly(:create, :converge, :setup, :destroy)
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
          logger: kind_of(::Kitchen::Logger),
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        ).and_return(create)
      )
      subject.finalize_config! kitchen_instance
    end

    context "when the action is a failure" do
      before do
        allow(create).to receive(:call).and_raise ::Kitchen::StandardError, "failure"
      end

      specify "should raise an action failed error" do
        expect do
          subject.create state
        end.to raise_error ::Kitchen::ActionFailed
      end
    end

    context "when the action is a success" do
      specify "should invoke the create strategy" do
        expect(create).to receive :call
      end

      after do
        subject.create state
      end
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
          logger: kind_of(::Kitchen::Logger),
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        ).and_return(destroy)
      )
      subject.finalize_config! kitchen_instance
    end

    context "when the action is a failure" do
      before do
        allow(destroy).to receive(:call).and_raise ::Kitchen::StandardError, "failure"
      end

      specify "should raise an action failed error" do
        expect do
          subject.destroy state
        end.to raise_error ::Kitchen::ActionFailed
      end
    end

    context "when the action is a success" do
      specify "should invoke the destroy strategy" do
        expect(destroy).to receive :call
      end

      after do
        subject.destroy state
      end
    end
  end

  describe "#doctor" do
    let :kitchen_instance_state do
      {}
    end

    specify "should return true" do
      expect(subject.doctor(kitchen_instance_state)).to be_truthy
    end
  end
end
