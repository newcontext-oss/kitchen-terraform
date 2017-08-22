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

require "dry/monads"
require "kitchen/logger"
require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options"
require "mixlib/shellout"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Command do
  shared_examples "a command is run" do |arguments:, subcommand:|
    include ::Dry::Monads::Either::Mixin

    subject do
      described_class.send subcommand, **arguments do |result|
        Right result
      end
    end

    shared_examples "the command experiences an error" do
      it do
        is_expected.to result_in_failure.with_the_value /Command failed: `terraform #{subcommand}.*`\n.+/
      end
    end

    context "when a permissions error occurs" do
      include_context "Kitchen::Terraform::Client::Command", error: ::Errno::EACCES,
                                                             subcommand: subcommand

      it_behaves_like "the command experiences an error"
    end

    context "when an entry error occurs" do
      include_context "Kitchen::Terraform::Client::Command", error: ::Errno::ENOENT,
                                                             subcommand: subcommand

      it_behaves_like "the command experiences an error"
    end

    context "when a timeout error occurs" do
      include_context "Kitchen::Terraform::Client::Command", error: ::Mixlib::ShellOut::CommandTimeout,
                                                             subcommand: subcommand

      it_behaves_like "the command experiences an error"
    end

    context "when the command exits with a nonzero value" do
      include_context "Kitchen::Terraform::Client::Command", subcommand: subcommand

      it_behaves_like "the command experiences an error"
    end

    context "when the command exits with a zero value" do
      include_context "Kitchen::Terraform::Client::Command", exit_code: 0,
                                                             subcommand: subcommand

      it do
        is_expected.to result_in_success.with_the_value "stdout"
      end
    end
  end

  describe ".apply" do
    it_behaves_like(
      "a command is run",
      arguments: {
        logger: ::Kitchen::Logger.new,
        options: [],
        target: "target",
        timeout: 1234,
        working_directory: "working_directory"
      },
      subcommand: "apply"
    )
  end

  describe ".init" do
    it_behaves_like(
      "a command is run",
      arguments: {
        logger: ::Kitchen::Logger.new,
        options: [],
        target: "target",
        timeout: 1234,
        working_directory: "working_directory"
      },
      subcommand: "init"
    )
  end

  describe ".output" do
    it_behaves_like(
      "a command is run",
      arguments: {
        logger: ::Kitchen::Logger.new,
        options: [],
        timeout: 1234,
        working_directory: "working_directory"
      },
      subcommand: "output"
    )
  end

  describe ".plan" do
    it_behaves_like(
      "a command is run",
      arguments: {
        logger: ::Kitchen::Logger.new,
        options: [],
        target: "target",
        timeout: 1234,
        working_directory: "working_directory"
      },
      subcommand: "plan"
    )
  end

  describe ".validate" do
    it_behaves_like(
      "a command is run",
      arguments: {
        logger: ::Kitchen::Logger.new,
        target: "target",
        timeout: 1234,
        working_directory: "working_directory"
      },
      subcommand: "validate"
    )
  end

  describe ".version" do
    it_behaves_like(
      "a command is run",
      arguments: {
        logger: ::Kitchen::Logger.new,
        working_directory: "working_directory"
      },
      subcommand: "version"
    )
  end
end
