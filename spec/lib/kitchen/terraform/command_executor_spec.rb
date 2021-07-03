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

require "kitchen/terraform/command_executor"
require "kitchen/terraform/shell_out"

::RSpec.describe ::Kitchen::Terraform::CommandExecutor do
  subject do
    described_class.new client: "./client", logger: logger
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  describe "#run" do
    let :options do
      { cwd: "/working", timeout: 123 }
    end

    let :shell_out do
      instance_double ::Kitchen::Terraform::ShellOut
    end

    let :standard_output do
      "stdout"
    end

    before do
      allow(::Kitchen::Terraform::ShellOut).to receive(:new).with(
        command: "./client test",
        logger: logger,
        options: options,
      ).and_return shell_out
      allow(shell_out).to receive(:run).and_yield standard_output
    end

    specify "should yield the standard output" do
      expect do |block|
        subject.run command: "test", options: options, &block
      end.to yield_with_args standard_output
    end
  end
end
