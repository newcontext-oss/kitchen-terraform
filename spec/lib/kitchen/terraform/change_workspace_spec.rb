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

require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/change_workspace"

::RSpec.describe ::Kitchen::Terraform::ChangeWorkspace do
  describe ".call" do
    let :directory do
      "/directory"
    end

    let :name do
      "name"
    end

    let :timeout do
      1234
    end

    context "when the workspace can not be selected or created" do
      let :error_message do
        "mocked `terraform workspace new <kitchen-instance>` failure"
      end

      before do
        allow(::Kitchen::Terraform::Command::WorkspaceSelect).to receive(:run).with(
          directory: directory,
          name: name,
          timeout: timeout,
        ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform workspace select <kitchen-instance>` failure"
        allow(::Kitchen::Terraform::Command::WorkspaceNew).to receive(:run).with(
          directory: directory,
          name: name,
          timeout: timeout,
        ).and_raise ::Kitchen::Terraform::Error, error_message
      end

      specify "should raise an error" do
        expect do
          described_class.call directory: directory, name: name, timeout: timeout
        end.to raise_error ::Kitchen::Terraform::Error, error_message
      end
    end

    context "when the workspace can not be selected but can be created" do
      before do
        allow(::Kitchen::Terraform::Command::WorkspaceSelect).to receive(:run).with(
          directory: directory,
          name: name,
          timeout: timeout,
        ).and_raise ::Kitchen::Terraform::Error, "mocked `terraform workspace select <kitchen-instance>` failure"
        allow(::Kitchen::Terraform::Command::WorkspaceNew).to receive(:run).with(
          directory: directory,
          name: name,
          timeout: timeout,
        )
      end

      specify "should not raise an error" do
        expect do
          described_class.call directory: directory, name: name, timeout: timeout
        end.not_to raise_error
      end
    end

    context "when the workspace can be selected" do
      before do
        allow(::Kitchen::Terraform::Command::WorkspaceSelect).to receive(:run).with(
          directory: directory,
          name: name,
          timeout: timeout,
        )
      end

      specify "should not raise an error" do
        expect do
          described_class.call directory: directory, name: name, timeout: timeout
        end.not_to raise_error
      end
    end
  end
end
