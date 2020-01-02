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
require "kitchen/terraform/command/version"
require "kitchen/terraform/command_executor"

::RSpec.describe ::Kitchen::Terraform::Command::Version do
  describe "#run" do
    subject do
      described_class.new client: client, logger: logger
    end

    let :client do
      "/usr/local/bin/terraform"
    end

    let :command_executor do
      instance_double ::Kitchen::Terraform::CommandExecutor
    end

    let :logger do
      ::Kitchen::Logger.new
    end

    let :options do
      { cwd: "/root-module-directory" }
    end

    before do
      allow(::Kitchen::Terraform::CommandExecutor)
        .to(receive(:new).with(client: client, logger: logger).and_return(command_executor))
    end

    context "when running the command results in success" do
      before do
        allow(command_executor)
          .to(receive(:run).with(command: "version", options: options).and_yield(standard_output: "Terraform v0.11.10"))
      end

      specify "should yield the version" do
        expect do |block|
          subject.run(options: options, &block)
        end.to yield_with_args version: ::Gem::Version.new("0.11.10")
      end
    end

    context "when running the command results in failure" do
      before do
        allow(command_executor).to(
          receive(:run).with(command: "version", options: options)
            .and_raise(::Kitchen::ShellOut::ShellCommandFailed, "shell command failed")
        )
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run options: options
        end.to raise_error ::Kitchen::TransientFailure
      end
    end
  end
end
