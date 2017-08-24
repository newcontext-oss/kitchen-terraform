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

require "kitchen/driver/terraform"
require "support/kitchen/instance_context"
require "support/kitchen/terraform/clear_directory_context"
require "support/kitchen/terraform/create_directories_context"
require "support/kitchen/terraform/client/command_context"

::RSpec.shared_context "Kitchen::Driver::Terraform finalized instance" do
  include_context ::Kitchen::Instance

  let :config do
    default_config
  end

  let :driver do
    ::Kitchen::Driver::Terraform.new config
  end

  before do
    driver.finalize_config! instance
  end
end

::RSpec.shared_context "Kitchen::Driver::Terraform#create failure" do
  include_context "Kitchen::Terraform::CreateDirectories.call failure"
end

::RSpec.shared_context "Kitchen::Driver::Terraform#create success" do
  include_context "Kitchen::Terraform::CreateDirectories.call success"

  include_context "Kitchen::Terraform::ClearDirectory"

  include_context "Kitchen::Terraform::Client::Command.init success"

  include_context "Kitchen::Terraform::Client::Command.validate success"

  include_context "Kitchen::Terraform::Client::Command.apply success"
end

::RSpec.shared_context "Kitchen::Driver::Terraform#output failure" do
  include_context "Kitchen::Terraform::Client::Command.output failure"
end

::RSpec.shared_context "Kitchen::Driver::Terraform#output success" do |output_contents: "output_contents"|
  include_context(
    "Kitchen::Terraform::Client::Command.output success",
    output_contents: output_contents
  )
end
