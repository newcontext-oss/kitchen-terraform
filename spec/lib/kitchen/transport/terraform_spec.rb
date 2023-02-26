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

require "kitchen"
require "kitchen/transport/terraform"
require "support/kitchen/logger_context"
require "support/kitchen/terraform/config_attribute/client_examples"
require "support/kitchen/terraform/config_attribute/command_timeout_examples"
require "support/kitchen/terraform/config_attribute/root_module_directory_examples"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Transport::Terraform do
  subject do
    described_class.new config
  end

  include_context "Kitchen::Logger"

  let :config do
    {}
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new(
      driver: ::Kitchen::Driver::Base.new,
      lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config, state_file),
      logger: logger,
      platform: ::Kitchen::Platform.new(name: "test-platform"),
      provisioner: ::Kitchen::Provisioner::Base.new,
      state_file: state_file,
      suite: ::Kitchen::Suite.new(name: "test-suite"),
      transport: subject,
      verifier: ::Kitchen::Verifier::Base.new,
    )
  end

  let :state do
    {}
  end

  let :state_file do
    ::Kitchen::StateFile.new "/kitchen", "test-suite-test-platform"
  end

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::Client"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::CommandTimeout"

  it_behaves_like "Kitchen::Terraform::ConfigAttribute::RootModuleDirectory"

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#connection" do
    before do
      subject.finalize_config! kitchen_instance
    end

    specify "should return a connection" do
      expect(subject.connection(state)).to be_kind_of ::Kitchen::Terraform::Transport::Connection
    end
  end

  describe "#doctor" do
    specify "should return true" do
      subject.finalize_config! kitchen_instance

      expect(subject.doctor(state)).to be_truthy
    end
  end
end
