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
require "kitchen/terraform/command/apply"
require "kitchen/terraform/command/get"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/validate"
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

  let :command_apply do
    instance_double ::Kitchen::Terraform::Command::Apply
  end

  let :command_get do
    instance_double ::Kitchen::Terraform::Command::Get
  end

  let :command_output do
    instance_double ::Kitchen::Terraform::Command::Output
  end

  let :command_validate do
    instance_double ::Kitchen::Terraform::Command::Validate
  end

  let :command_workspace_select do
    instance_double ::Kitchen::Terraform::Command::WorkspaceSelect
  end

  let :config do
    { root_module_directory: root_module_directory, variables: { variable_name: "variable_value" } }
  end

  let :logger do
    ::Kitchen::Logger.new
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
    allow(::Kitchen::Terraform::Command::Apply).to(
      receive(:new).with(config: config, logger: logger).and_return(command_apply)
    )
    allow(::Kitchen::Terraform::Command::Get).to(
      receive(:new).with(config: config, logger: logger).and_return(command_get)
    )
    allow(::Kitchen::Terraform::Command::Output).to(
      receive(:new).with(config: config, logger: kind_of(::Kitchen::Terraform::DebugLogger)).and_return(command_output)
    )
    allow(::Kitchen::Terraform::Command::Validate).to(
      receive(:new).with(config: config, logger: logger).and_return(command_validate)
    )
    allow(::Kitchen::Terraform::Command::WorkspaceSelect).to(
      receive(:new).with(config: config, logger: logger).and_return(command_workspace_select)
    )
    allow(::Kitchen::Terraform::VerifyVersion).to receive(:new).with(
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
        expect(verify_version).to receive(:call).ordered
        expect(command_workspace_select).to receive(:run).with(workspace_name: workspace_name).ordered
        expect(command_get).to receive(:run).ordered
        expect(command_validate).to receive(:run).ordered
        expect(command_apply).to receive(:run).ordered
        expect(command_output).to receive(:run).ordered
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
        allow(verify_version).to receive :call
        allow(command_workspace_select).to receive(:run).with workspace_name: workspace_name
        allow(command_get).to receive :run
        allow(command_validate).to receive :run
        allow(command_apply).to receive :run
        allow(command_output).to receive(:run).and_yield outputs: { output_name: { value: "output_value" } }
        subject.call state: state
        ::Kitchen::Terraform::VariablesManager.new(logger: logger).load variables: variables, state: state
        ::Kitchen::Terraform::OutputsManager.new(logger: logger).load outputs: outputs, state: state
      end

      specify "should store variables in the Kitchen instance state" do
        expect(variables).to eq variable_name: "variable_value"
      end

      specify "should store outputs in the Kitchen instance state" do
        expect(outputs).to eq output_name: { value: "output_value" }
      end
    end
  end
end
