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

require "support/kitchen/terraform/client/execute_command_context"

::RSpec.shared_context "Kitchen::Terraform::Client::Version" do |failure: true, version: 99.9|
  include_context "Kitchen::Terraform::Client::ExecuteCommand",
                  command: "version",
                  exit_code: (failure and 1 or 0),
                  output: "Terraform v#{version}"
end
