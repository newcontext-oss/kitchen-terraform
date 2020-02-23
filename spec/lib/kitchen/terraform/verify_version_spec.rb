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
require "kitchen/terraform/command_executor"
require "kitchen/terraform/command/version"
require "kitchen/terraform/unsupported_client_version_error"
require "kitchen/terraform/verify_version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VerifyVersion do
  subject do
    described_class.new(
      command_executor: command_executor,
      config: config,
      logger: logger,
      version_requirement: version_requirement,
    )
  end

  let :command_executor do
    instance_double ::Kitchen::Terraform::CommandExecutor
  end

  let :config do
    { verify_version: verify_version }
  end

  let :logger do
    ::Kitchen::Logger.new
  end

  let :verify_version do
    true
  end

  let :version_requirement do
    ::Gem::Requirement.new "~> 1.2.3"
  end

  describe "#call" do
    let :options do
      {}
    end

    let :version do
      instance_double ::Kitchen::Terraform::Command::Version
    end

    before do
      allow(command_executor).to receive(:run).with(command: version, options: options).and_yield(
        standard_output: standard_output,
      )
    end

    context "when the version is not supported" do
      let :standard_output do
        "Terraform v0.1.2"
      end

      context "when driver.verify_version is true" do
        specify "should raise an error" do
          expect do
            subject.call command: version, options: options
          end.to raise_error ::Kitchen::Terraform::UnsupportedClientVersionError
        end
      end

      context "when driver.verify_version is false" do
        let :verify_version do
          false
        end

        specify "should not raise an error" do
          expect do
            subject.call command: version, options: options
          end.not_to raise_error
        end
      end
    end

    context "when the version is supported" do
      let :standard_output do
        "Terraform v1.2.4"
      end

      specify "should not raise an error" do
        expect do
          subject.call command: version, options: options
        end.not_to raise_error
      end
    end
  end
end
