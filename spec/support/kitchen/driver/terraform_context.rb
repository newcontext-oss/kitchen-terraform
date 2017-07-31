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

require "support/kitchen/terraform/clear_directory_context"
require "support/kitchen/terraform/client/command_context"
require "support/kitchen/terraform/create_directories_context"

::RSpec.shared_context "Kitchen::Driver::Terraform" do |failure: true|
  include_context "Kitchen::Terraform::CreateDirectories", failure: false

  include_context "Kitchen::Terraform::ClearDirectory"

  include_context "Kitchen::Terraform::Client::Command", exit_code: 0,
                                                         subcommand: "validate"

  include_context "Kitchen::Terraform::Client::Command", exit_code: 0,
                                                         subcommand: "init"

  include_context "Kitchen::Terraform::Client::Command", exit_code: 0,
                                                         subcommand: "plan"

  include_context "Kitchen::Terraform::Client::Command", exit_code: (failure and 1 or 0),
                                                         subcommand: "apply"
end
