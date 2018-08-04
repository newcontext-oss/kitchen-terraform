# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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
require "kitchen/driver/terraform"
require "kitchen/provisioner/terraform"
require "kitchen/transport/ssh"
require "kitchen/verifier/terraform"

::RSpec.shared_context "Kitchen::Instance" do
  let :default_config do
    {kitchen_root: kitchen_root}
  end

  let :driver do
    ::Kitchen::Driver::Terraform.new default_config
  end

  let :instance do
    ::Kitchen::Instance.new driver: driver, lifecycle_hooks: lifecycle_hooks, logger: logger, platform: platform,
                            provisioner: provisioner, state_file: object, suite: suite, transport: transport,
                            verifier: verifier
  end

  let :kitchen_root do
    "/kitchen/root"
  end

  let :lifecycle_hooks do
    ::Kitchen::LifecycleHooks.new default_config
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :platform do
    ::Kitchen::Platform.new name: "platform"
  end

  let :provisioner do
    ::Kitchen::Provisioner::Terraform.new default_config
  end

  let :suite do
    ::Kitchen::Suite.new name: "suite"
  end

  let :transport do
    ::Kitchen::Transport::Ssh.new
  end

  let :verifier do
    ::Kitchen::Verifier::Terraform.new default_config
  end
end
