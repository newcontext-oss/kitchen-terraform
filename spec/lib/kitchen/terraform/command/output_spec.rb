# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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
require "kitchen/terraform/command/output"
require "kitchen/terraform/shell_out_nu"

::RSpec.describe ::Kitchen::Terraform::Command::Output do
  describe ".run" do
    let :color do
      false
    end

    let :command_output do
      "{\"key\":\"value\"}"
    end

    let :directory do
      "/directory"
    end

    let :timeout do
      1234
    end

    let :output do
      described_class.new color: color
    end

    before do
      allow(::Kitchen::Terraform::ShellOutNu).to receive(:run_command).with(
        "terraform output -json -no-color",
        cwd: directory,
        environment: kind_of(::Hash),
        timeout: timeout,
      ).and_return command_output
    end

    specify "should yield the result of running `terraform output`" do
      expect do |block|
        described_class.run(
          color: false,
          directory: directory,
          timeout: timeout,
          &block
        )
      end.to yield_with_args output: output
    end
  end
end
