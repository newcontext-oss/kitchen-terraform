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
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/transport/connection"
require "kitchen/terraform/verify_version"
require "rubygems"
require "support/kitchen/logger_context"

::RSpec.describe ::Kitchen::Terraform::Driver::Create do
  subject do
    described_class.new(
      config: config,
      connection: connection,
      logger: logger,
      workspace_name: double(::String),
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
      plugin_directory: "test-plugin-directory",
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
    context "when the desired workspace does not exist" do
      specify "should verify the version, initialize the working directory, and create the workspace" do
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).ordered
        expect(connection).to receive(:execute)
            .with(kind_of(::Kitchen::Terraform::Command::Init::PreZeroFifteenZero)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceNew)).ordered
        expect(connection).not_to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect))

        subject.call
      end
    end

    context "when the desired workspace does exist" do
      specify "should verify the version, initialize the working directory, and select the workspace" do
        # Kitchen::Transport::Exec::Connection#execute does not wrap exceptions as documented.
        allow(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceNew)).and_raise ::Kitchen::ShellOut::ShellCommandFailed, "workspace already exists"

        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::Version)).ordered
        expect(connection).to receive(:execute)
            .with(kind_of(::Kitchen::Terraform::Command::Init::PreZeroFifteenZero)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceNew)).ordered
        expect(connection).to receive(:execute).with(kind_of(::Kitchen::Terraform::Command::WorkspaceSelect)).ordered

        subject.call
      end
    end
  end
end
