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

require "kitchen/terraform/command/workspace_new"

::RSpec.describe ::Kitchen::Terraform::Command::WorkspaceNew do
  describe "#to_s" do
    subject do
      described_class.new config: config
    end

    let :config do
      { root_module_directory: "/root-module", workspace_name: "test" }
    end

    specify "should return the command" do
      expect(subject.to_s).to eq "workspace new test"
    end
  end
end
