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
      instance_double ::Kitchen::Terraform::Client
    end

    before do
      allow(::Kitchen::Terraform::Client).to receive(:new).and_return client
      allow(client).to receive :if_version_not_supported
    end

    def run_general_command_failure(command:, message: "mocked `terraform` failure")
      allow(client)
        .to(
          receive(command)
            .and_raise(
              ::Kitchen::ShellOut::ShellCommandFailed,
              message
            )
        )
    end

    def run_specific_command_failure(command:, flags:, message: "mocked `terraform` failure")
      allow(client)
        .to(
          receive(command)
            .with(flags: flags)
            .and_raise(
              ::Kitchen::ShellOut::ShellCommandFailed,
              message
            )
        )
    end

    def run_general_command_success(command:)
      allow(client).to receive command
    end

    def run_specific_command_success(command:, flags:)
      allow(client).to receive(command).with flags: flags
    end
  end
