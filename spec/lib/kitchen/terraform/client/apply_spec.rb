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

require "kitchen/terraform/client/apply"

::RSpec.describe ::Kitchen::Terraform::Client::Apply do
  describe ".call" do
    let :config do
      {
        color: "color",
        parallelism: "parallelism",
        plan: "plan",
        state: "state"
      }
    end

    after do
      described_class.call config: config, logger: "logger"
    end

    subject do
      ::Kitchen::Terraform::Client::ExecuteCommand
    end

    it "executes the command" do
      is_expected.to receive(:call)
        .with command: "apply",
              config: config,
              logger: "logger",
              options: {
                color: "color",
                input: false,
                parallelism: "parallelism",
                state_out: "state"
              },
              target: "plan"
    end
  end
end

require "kitchen/terraform/client/execute_command"
