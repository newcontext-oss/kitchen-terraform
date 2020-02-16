# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
require "kitchen/terraform/provisioner/converge"
require "rubygems"
require "support/kitchen/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Provisioner::Terraform do
  subject do
    described_class.new config
  end

  let :config do
    {}
  end

  let :converge do
    instance_double ::Kitchen::Terraform::Provisioner::Converge
  end

  let :driver do
    ::Kitchen::Driver::Terraform.new driver_config
  end

  let :driver_config do
    {}
  end

  let :kitchen_instance do
    ::Kitchen::Instance.new(
      driver: driver,
      lifecycle_hooks: ::Kitchen::LifecycleHooks.new(config),
      logger: kitchen_logger,
      platform: ::Kitchen::Platform.new(name: "test-platform"),
      provisioner: subject,
      state_file: ::Kitchen::StateFile.new("/kitchen", "test-suite-test-platform"),
      suite: ::Kitchen::Suite.new(name: "test-suite"),
      transport: ::Kitchen::Transport::Base.new,
      verifier: ::Kitchen::Verifier::Base.new,
    )
  end

  let :kitchen_logger do
    ::Kitchen::Logger.new
  end

  before do
    allow(::Kitchen::Terraform::Provisioner::Converge).to(
      receive(:new).with(
        config: driver_config,
        logger: kitchen_logger,
        version_requirement: kind_of(::Gem::Requirement),
        workspace_name: kind_of(::String),
      ).and_return(converge)
    )
  end

  it_behaves_like "Kitchen::Terraform::Configurable"

  describe "#call" do
    let :state do
      {}
    end

    before do
      subject.finalize_config! kitchen_instance
    end

    context "when the action is a failure" do
      before do
        allow(converge).to receive(:call).and_raise ::Kitchen::StandardError, "failure"
      end

      specify "should raise an action failed error" do
        expect do
          subject.call state
        end.to raise_error ::Kitchen::ActionFailed
      end
    end

    context "when the action is a success" do
      before do
        allow(converge).to receive :call
      end

      specify "should not raise an error" do
        expect do
          subject.call state
        end.not_to raise_error
      end
    end
  end
end
