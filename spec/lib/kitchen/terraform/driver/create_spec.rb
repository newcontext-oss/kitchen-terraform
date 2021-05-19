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
require "kitchen/terraform/command_executor"
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/verify_version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::Driver::Create do
  subject do
    described_class.new(
      config: config,
      logger: logger,
      workspace_name: workspace_name,
      version_requirement: version_requirement,
    )
  end

  let :config do
    {
      backend_configurations: {},
      client: client,
      color: true,
      command_timeout: command_timeout,
      lock: true,
      lock_timeout: 123,
      plugin_directory: "",
      root_module_directory: root_module_directory,
      verify_version: true,
    }
  end

  let :client do
    "/client"
  end

  let :command_executor do
    instance_double ::Kitchen::Terraform::CommandExecutor
  end

  let :command_timeout do
    123
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :options do
    { cwd: root_module_directory, timeout: command_timeout }
  end

  let :root_module_directory do
    "/root-module"
  end

  let :workspace_name do
    "test"
  end

  let :version_requirement do
    ::Gem::Requirement.new ">= 0.1.0"
  end

  before do
    allow(::Kitchen::Terraform::CommandExecutor).to receive(:new).with(client: client, logger: logger).and_return(
      command_executor
    )
    allow(command_executor).to receive(:run).with(
      command: kind_of(::Kitchen::Terraform::Command::Version),
      options: options,
    ).and_yield standard_output: "Terraform v0.11.4"
  end

  describe "#call" do
    context "when the desired workspace does not exist" do
      specify "should verify the version, initialize the working directory, and create the workspace" do
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Version),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Init::PreZeroFifteenZero),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceNew),
          options: options,
        ).ordered
        expect(command_executor).not_to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceSelect),
          options: options,
        )
      end

      after do
        subject.call
      end
    end

    context "when the desired workspace does exist" do
      before do
        allow(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceNew),
          options: options,
        ).and_raise ::Kitchen::TransientFailure, "workspace already exists"
      end

      specify "should verify the version, initialize the working directory, and select the workspace" do
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Version),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Init::PreZeroFifteenZero),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceNew),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceSelect),
          options: options,
        ).ordered
      end

      after do
        subject.call
      end
    end
  end
end
