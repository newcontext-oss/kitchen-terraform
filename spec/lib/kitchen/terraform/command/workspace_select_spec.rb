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
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/shell_out"

::RSpec.describe ::Kitchen::Terraform::Command::WorkspaceSelect do
  describe ".call" do
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

    let :workspace_select do
      described_class.new name: name
    end

    before do
      allow(::Kitchen::Terraform::ShellOut).to receive(:run_command).with(
        "terraform workspace select #{name}",
        cwd: directory,
        environment: kind_of(::Hash),
        timeout: timeout,
      ).and_return output
    end

    specify "should yield the result of running `terraform workspace select`" do
      expect do |block|
        described_class.call directory: directory, name: name, timeout: timeout, &block
      end.to yield_with_args workspace_select: workspace_select
    end
  end
end
