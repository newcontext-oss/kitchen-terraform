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
require "kitchen/terraform/client"

::RSpec
  .shared_context "Kitchen::Terraform::Client" do
    let :client do
      ::Kitchen::Terraform::Client.new
    end

    def run_command_failure(command:, message: "mocked `terraform` failure")
      allow(client)
        .to(
          receive(:run_command)
            .with(
              command,
              environment:
                {
                  "LC_ALL" => nil,
                  "TF_IN_AUTOMATION" => true
                },
              timeout: 600
            )
            .and_raise(
              ::Kitchen::ShellOut::ShellCommandFailed,
              message
            )
        )
    end

    def run_command_success(command:, return_value: "mocked `terraform` success")
      allow(client)
        .to(
          receive(:run_command)
            .with(
              command,
              environment:
                {
                  "LC_ALL" => nil,
                  "TF_IN_AUTOMATION" => true
                },
              timeout: 600
            )
            .and_return(return_value)
        )
    end
  end
