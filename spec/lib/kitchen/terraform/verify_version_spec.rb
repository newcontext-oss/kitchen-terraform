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
require "kitchen/terraform/command/version"
require "kitchen/terraform/verify_version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VerifyVersion do
  subject do
    described_class.new config: config, logger: logger, version_requirement: version_requirement
  end

  let :client do
    "/client"
  end

  let :config do
    { client: client, root_module_directory: root_module_directory, verify_version: verify_version }
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :root_module_directory do
    "/root-module"
  end

  let :verify_version do
    true
  end

  let :version_command do
    instance_double ::Kitchen::Terraform::Command::Version
  end

  let :version_requirement do
    ::Gem::Requirement.new "~> 1.2.3"
  end

  before do
    allow(::Kitchen::Terraform::Command::Version).to receive(:new).with(client: client, logger: logger).and_return(
      version_command
    )
  end

  describe "#call" do
    before do
      allow(version_command).to receive(:run).with(options: { cwd: root_module_directory }).and_yield version: version
    end

    context "when the version is not supported" do
      let :version do
        ::Gem::Version.new "0.1.2"
      end

      context "when driver.verify_version is true" do
        specify "should raise an error because the action failed" do
          expect do
            subject.call
          end.to raise_error ::Kitchen::ActionFailed
        end
      end

      context "when driver.verify_version is false" do
        let :verify_version do
          false
        end

        specify "should not raise an error" do
          expect do
            subject.call
          end.not_to raise_error
        end
      end
    end

    context "when the version is supported" do
      let :version do
        ::Gem::Version.new "1.2.4"
      end

      specify "should not raise an error" do
        expect do
          subject.call
        end.not_to raise_error
      end
    end
  end
end
