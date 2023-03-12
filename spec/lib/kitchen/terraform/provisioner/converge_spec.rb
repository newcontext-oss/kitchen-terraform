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
require "kitchen/terraform/command/apply"
require "kitchen/terraform/command/get"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/debug_logger"
require "kitchen/terraform/outputs_manager"
require "kitchen/terraform/provisioner/converge"
require "kitchen/terraform/transport/connection"
require "kitchen/terraform/variables_manager"
require "kitchen/terraform/verify_version"
require "rubygems"
require "support/kitchen/logger_context"

::RSpec.describe ::Kitchen::Terraform::Provisioner::Converge do
  subject do
    described_class.new(
      config: config,
      connection: connection,
      debug_connection: debug_connection,
      logger: ::Kitchen.logger,
      workspace_name: "test-workspace",
      version_requirement: ::Gem::Requirement.new(">= 0.1.0"),
    )
  end

  include_context "Kitchen::Logger"

  let :config do
    {
      color: true,
      lock: true,
      lock_timeout: 123,
      parallelism: 456,
      variable_files: [],
      variables: { variable_name: "variable_value" },
      verify_version: true,
    }
  end

  let :connection do
    instance_double ::Kitchen::Terraform::Transport::Connection
  end

  let :debug_connection do
    instance_double ::Kitchen::Terraform::Transport::Connection
  end

  before do
    allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).and_return "Terraform v0.11.4"
  end

  describe "#call" do
    describe "the workflow" do
      specify(
        "should verify the version, select the workspace, update the modules, validate the configuration, update " \
        "the Terraform state, and retrieve the outputs"
      ) do
        allow(debug_connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Output)).and_return "{ \"output_name\": { \"value\": \"output_value\" } }"

        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Get)).ordered
        expect(connection).to receive(:execute)
                                .with(kind_of(::Kitchen::Terraform::Command::Validate::PreZeroFifteenZero)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Apply)).ordered
        expect(debug_connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Output)).ordered

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

      specify "should store variables and outputs in the Kitchen instance state" do
        allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).and_return "Terraform v0.11.4"
        allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect))
        allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Get))
        allow(connection).to receive(:execute)
                               .with(kind_of(::Kitchen::Terraform::Command::Validate::PreZeroFifteenZero))
        allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Apply))
        allow(debug_connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Output)).and_return "{ \"output_name\": { \"value\": \"output_value\" } }"

        subject.call state: state
        ::Kitchen::Terraform::VariablesManager.new.load variables: variables, state: state
        ::Kitchen::Terraform::OutputsManager.new.load outputs: outputs, state: state

        expect(variables).to eq variable_name: "variable_value"
        expect(outputs).to eq "output_name" => { "value" => "output_value" }
      end
    end
  end
end
