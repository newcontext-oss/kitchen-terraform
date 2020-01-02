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
require "kitchen/terraform/version_verifier"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VersionVerifier do
  describe "#verify" do
    subject do
      described_class.new command: command, logger: ::Kitchen::Logger.new
    end

    let :command do
      instance_double ::Kitchen::Terraform::Command::Version
    end

    let :options do
      { cwd: "/root-module-directory" }
    end

    let :requirement do
      ::Gem::Requirement.new "~> 1.2.3"
    end

    context "when running the command fails" do
      before do
        allow(command).to(
          receive(:run).with(options: options)
            .and_raise(::Kitchen::TransientFailure, "Failed to run the version command.")
        )
      end

      specify "should raise an error" do
        expect do
          subject.verify options: options, requirement: requirement, strict: true
        end.to raise_error ::Kitchen::TransientFailure, "Failed verification of the Terraform client version."
      end
    end

    context "when the version does not meet the requirement" do
      before do
        allow(command).to receive(:run).with(options: options).and_yield version: ::Gem::Version.new("0.1.2")
      end

      context "when strict mode is enabled" do
        specify "should raise an error" do
          expect do
            subject.verify options: options, requirement: requirement, strict: true
          end.to raise_error ::Kitchen::UserError, "Failed verification of the Terraform client version."
        end
      end

      context "when strict mode is disabled" do
        specify "should not raise an error" do
          expect do
            subject.verify options: options, requirement: requirement, strict: false
          end.not_to raise_error
        end
      end
    end

    context "when the version does meet the requirement" do
      before do
        allow(command).to receive(:run).with(options: options).and_yield version: ::Gem::Version.new("1.2.4")
      end

      context "when strict mode is enabeld" do
        specify "should not raise an error" do
          expect do
            subject.verify options: options, requirement: requirement, strict: true
          end.not_to raise_error
        end
      end

      context "when strict mode is disabled" do
        specify "should not raise an error" do
          expect do
            subject.verify options: options, requirement: requirement, strict: false
          end.not_to raise_error
        end
      end
    end
  end
end
