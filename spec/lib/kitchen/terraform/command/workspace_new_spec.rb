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
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/shell_out_nu"

::RSpec.describe ::Kitchen::Terraform::Command::WorkspaceNew do
  describe ".run" do
    let :directory do
      "/directory"
    end

    let :name do
      "name"
    end

    let :output do
      "output"
    end

    let :timeout do
      1234
    end

    let :workspace_new do
      described_class.new name: name
    end

    before do
      allow(::Kitchen::Terraform::ShellOutNu).to receive(:run_command).with(
        "terraform workspace new #{name}",
        cwd: directory,
        environment: kind_of(::Hash),
        timeout: timeout,
      ).and_return output
    end

    specify "should yield the result of running `terraform workspace new`" do
      expect do |block|
        described_class.run directory: directory, name: name, timeout: timeout, &block
      end.to yield_with_args workspace_new: workspace_new
    end
  end
end
