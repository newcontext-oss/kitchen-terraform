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
require "kitchen/shell_out"
require "kitchen/terraform/command/destroy"
require "kitchen/terraform/command/workspace_delete"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/driver/destroy"
require "kitchen/terraform/transport/connection"
require "kitchen/terraform/verify_version"
require "rubygems"
require "support/kitchen/logger_context"

::RSpec.describe ::Kitchen::Terraform::Driver::Destroy do
  subject do
    described_class.new(
      config: config,
      connection: connection,
      logger: ::Kitchen.logger,
      workspace_name: "test-workspace",
      version_requirement: ::Gem::Requirement.new(">= 0.1.0"),
    )
  end

  include_context "Kitchen::Logger"

  let :config do
    {
      backend_configurations: {},
      color: true,
      lock: true,
      lock_timeout: 123,
      parallelism: 456,
      plugin_directory: "",
      variable_files: [],
      variables: {},
      verify_version: true,
    }
  end

  let :connection do
    instance_double ::Kitchen::Terraform::Transport::Connection
  end

  before do
    allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).and_return "Terraform v0.11.4"
  end

  describe "#call" do
    context "when the desired workspace does exist" do
      specify(
        "should verify the version, initialize the working directory, select the workspace, destroy the state, and " \
        "delete the workspace"
      ) do
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Init::PreZeroFifteenZero))
                                .ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)).ordered
        expect(connection).not_to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceNew))
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Destroy)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceDelete)).ordered

        subject.call
      end
    end

    context "when the desired workspace does not exist" do
      specify(
        "should verify the version, initialize the working directory, create the workspace, destroy the state, and " \
        "delete the workspace"
      ) do
        call_count = 0
        allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)) do
          if call_count == 0
            call_count += 1
            # Kitchen::Transport::Exec::Connection#execute does not wrap exceptions as documented.
            raise ::Kitchen::ShellOut::ShellCommandFailed, "no such workspace"
          end
        end

        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Init::PreZeroFifteenZero))
                                .ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceNew)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Destroy)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceDelete)).ordered

        subject.call
      end
    end
  end
end
