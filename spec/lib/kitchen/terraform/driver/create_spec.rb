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

require "kitchen"
require "kitchen/terraform/command/init"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/verify_version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::Driver::Create do
  subject do
    described_class.new(
      config: base_config,
      logger: logger,
      workspace_name: workspace_name,
      version_requirement: version_requirement,
    )
  end

  let :base_config do
    { root_module_directory: root_module_directory }
  end

  let :command_init do
    instance_double ::Kitchen::Terraform::Command::Init
  end

  let :command_workspace_new do
    instance_double ::Kitchen::Terraform::Command::WorkspaceNew
  end

  let :command_workspace_select do
    instance_double ::Kitchen::Terraform::Command::WorkspaceSelect
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :modified_config do
    { root_module_directory: root_module_directory, upgrade_during_init: true }
  end

  let :root_module_directory do
    "/root-module"
  end

  let :verify_version do
    instance_double ::Kitchen::Terraform::VerifyVersion
  end

  let :workspace_name do
    "test"
  end

  let :version_requirement do
    instance_double ::Gem::Requirement
  end

  before do
    allow(::Kitchen::Terraform::Command::Init).to receive(:new).with(
      config: modified_config,
      logger: logger,
    ).and_return command_init
    allow(::Kitchen::Terraform::Command::WorkspaceNew).to receive(:new).with(
      config: base_config,
      logger: logger,
    ).and_return command_workspace_new
    allow(::Kitchen::Terraform::Command::WorkspaceSelect).to(
      receive(:new).with(config: base_config, logger: logger).and_return(command_workspace_select)
    )
    allow(::Kitchen::Terraform::VerifyVersion).to receive(:new).with(
      config: base_config,
      logger: logger,
      version_requirement: version_requirement,
    ).and_return verify_version
  end

  describe "#call" do
    context "when the desired workspace does not exist" do
      specify "should verify the version, initialize the working directory, and create the workspace" do
        expect(verify_version).to receive(:call).ordered
        expect(command_init).to receive(:run).ordered
        expect(command_workspace_new).to receive(:run).with(workspace_name: workspace_name).ordered
        expect(command_workspace_select).not_to receive :run
      end

      after do
        subject.call
      end
    end

    context "when the desired workspace does exist" do
      before do
        allow(command_workspace_new).to receive(:run).with(workspace_name: workspace_name).and_raise(
          ::Kitchen::TransientFailure, "workspace already exists"
        )
      end

      specify "should verify the version, initialize the working directory, and select the workspace" do
        expect(verify_version).to receive(:call).ordered
        expect(command_init).to receive(:run).ordered
        expect(command_workspace_new).to receive(:run).with(workspace_name: workspace_name).ordered
        expect(command_workspace_select).to receive(:run).with(workspace_name: workspace_name).ordered
      end

      after do
        subject.call
      end
    end
  end
end
