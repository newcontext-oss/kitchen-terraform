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
require "kitchen/terraform/command/apply"
require "kitchen/terraform/command/get"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/validate"
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/debug_logger"
require "kitchen/terraform/outputs_manager"
require "kitchen/terraform/provisioner/converge"
require "kitchen/terraform/variables_manager"
require "kitchen/terraform/verify_version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::Provisioner::Converge do
  subject do
    described_class.new(
      config: config,
      logger: logger,
      workspace_name: workspace_name,
      version_requirement: version_requirement,
    )
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

  let :config do
    {
      client: client,
      color: true,
      command_timeout: command_timeout,
      lock: true,
      lock_timeout: 123,
      parallelism: 456,
      root_module_directory: root_module_directory,
      variable_files: [],
      variables: { variable_name: "variable_value" },
    }
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

  let :verify_version do
    instance_double ::Kitchen::Terraform::VerifyVersion
  end

  let :version_requirement do
    instance_double ::Gem::Requirement
  end

  let :workspace_name do
    "test"
  end

  before do
    allow(::Kitchen::Terraform::CommandExecutor).to receive(:new).with(
      client: client,
      logger: logger,
    ).and_return command_executor
    allow(::Kitchen::Terraform::VerifyVersion).to receive(:new).with(
      command_executor: command_executor,
      config: config,
      logger: logger,
      version_requirement: version_requirement,
    ).and_return verify_version
  end

  describe "#call" do
    describe "the workflow" do
      specify(
        "should verify the version, select the workspace, update the modules, validate the configuration, update " \
        "the Terraform state, and retrieve the outputs"
      ) do
        expect(verify_version).to receive(:call).with(
          command: kind_of(::Kitchen::Terraform::Command::Version),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceSelect),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Get),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Validate),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Apply),
          options: options,
        ).ordered
        expect(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Output),
          options: options,
        ).ordered
      end

      after do
        subject.call state: {}
      end
    end

    describe "updating the Kitchen instance state" do
      let :outputs do
        {}
      end

      let :state do
        {}
      end

      let :variables do
        {}
      end

      before do
        allow(verify_version).to receive(:call).with(
          command: kind_of(::Kitchen::Terraform::Command::Version),
          options: options,
        )
        allow(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::WorkspaceSelect),
          options: options,
        )
        allow(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Get),
          options: options,
        )
        allow(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Validate),
          options: options,
        )
        allow(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Apply),
          options: options,
        )
        allow(command_executor).to receive(:run).with(
          command: kind_of(::Kitchen::Terraform::Command::Output),
          options: options,
        ).and_yield standard_output: "{ \"output_name\": { \"value\": \"output_value\" } }"
        subject.call state: state
        ::Kitchen::Terraform::VariablesManager.new.load variables: variables, state: state
        ::Kitchen::Terraform::OutputsManager.new.load outputs: outputs, state: state
      end

      specify "should store variables in the Kitchen instance state" do
        expect(variables).to eq variable_name: "variable_value"
      end

      specify "should store outputs in the Kitchen instance state" do
        expect(outputs).to eq "output_name" => { "value" => "output_value" }
      end
    end
  end
end
