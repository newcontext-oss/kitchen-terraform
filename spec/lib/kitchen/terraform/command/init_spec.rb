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
require "kitchen/terraform/command_executor"

::RSpec.describe ::Kitchen::Terraform::Command::Init do
  describe "#run" do
    subject do
      described_class.new config: config, logger: logger
    end

    let :client do
      "/client"
    end

    let :command_timeout do
      456
    end

    let :config do
      {
        backend_configurations: {
          string: "\\\"A String\\\"",
          map: "{ key = \\\"A Value\\\" }",
          list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
        },
        client: client,
        color: false,
        command_timeout: command_timeout,
        lock: true,
        lock_timeout: 123,
        plugin_directory: "/plugins",
        root_module_directory: root_module_directory,
        upgrade_during_init: upgrade_during_init,
      }
    end

    let :command_executor do
      instance_double ::Kitchen::Terraform::CommandExecutor
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

    let :upgrade_during_init do
      true
    end

    before do
      allow(::Kitchen::Terraform::CommandExecutor).to receive(:new).with(client: client, logger: logger).and_return(
        command_executor
      )
    end

    context "when running the command results in failure" do
      before do
        allow(command_executor).to receive(:run).with(command: /init/, options: options).and_raise(
          ::Kitchen::ShellOut::ShellCommandFailed, "shell command failed"
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when running the command results in success" do
      before do
        allow(command_executor).to receive(:run).with(
          command: "init " \
          "-input=false " \
          "-lock=true " \
          "-lock-timeout=123s " \
          "-no-color " \
          "-upgrade " \
          "-force-copy " \
          "-backend=true " \
          "-backend-config=\"string=\\\"A String\\\"\" " \
          "-backend-config=\"map={ key = \\\"A Value\\\" }\" " \
          "-backend-config=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
          "-get=true " \
          "-get-plugins=true " \
          "-plugin-dir=\"/plugins\" " \
          "-verify-plugins=true",
          options: options,
        ).and_yield standard_output: "stdout"
      end

      specify "should not raise an error" do
        expect do
          subject.run
        end.not_to raise_error
      end
    end
  end
end
