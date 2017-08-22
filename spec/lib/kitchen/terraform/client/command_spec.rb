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

require "kitchen/logger"
require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options"
require "mixlib/shellout"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Command do
  shared_examples "a command is run" do |subcommand:|
    shared_examples "the command experiences an error" do |message:|
      it do
        is_expected.to result_in_failure.with_the_value kind_of described_class
      end

      it do
        is_expected.to result_in_failure.with_the_value matching "terraform #{subcommand}"
      end

      it do
        is_expected.to result_in_failure.with_the_value matching message
      end
    end

    context "when a permissions error occurs" do
      include_context(
        "Kitchen::Terraform::Client::Command error failure",
        error: ::Errno::EACCES,
        subcommand: subcommand
      )

      it_behaves_like(
        "the command experiences an error",
        message: "Permission denied - mocked error"
      )
    end

    context "when an entry error occurs" do
      include_context(
        "Kitchen::Terraform::Client::Command error failure",
        error: ::Errno::ENOENT,
        subcommand: subcommand
      )

      it_behaves_like(
        "the command experiences an error",
        message: "No such file or directory - mocked error"
      )
    end

    context "when a timeout error occurs" do
      include_context(
        "Kitchen::Terraform::Client::Command error failure",
        error: ::Mixlib::ShellOut::CommandTimeout,
        subcommand: subcommand
      )

      it_behaves_like(
        "the command experiences an error",
        message: "mocked error"
      )
    end

    context "when the command exits with a nonzero value" do
      include_context(
        "Kitchen::Terraform::Client::Command status failure",
        subcommand: subcommand
      )

      it_behaves_like(
        "the command experiences an error",
        message: "Begin output of terraform #{subcommand}"
      )
    end

    context "when the command exits with a zero value" do
      include_context(
        "Kitchen::Terraform::Client::Command success",
        subcommand: subcommand
      )

      it do
        is_expected.to result_in_success.with_the_value kind_of described_class
      end

      it do
        is_expected.to result_in_success.with_the_value matching "terraform #{subcommand}"
      end
    end
  end

  describe ".apply" do
    subject do
      described_class
        .apply(
          logger: ::Kitchen::Logger.new,
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .no_color,
          timeout: 1234,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "apply -no-color"
    )
  end

  describe ".destroy" do
    subject do
      described_class
        .destroy(
          logger: ::Kitchen::Logger.new,
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .no_color,
          timeout: 1234,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "destroy -no-color"
    )
  end

  describe ".init" do
    subject do
      described_class
        .init(
          logger: ::Kitchen::Logger.new,
          options:
            ::Kitchen::Terraform::Client::Options.new.no_color,
          timeout: 1234,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "init -no-color"
    )
  end

  describe ".output" do
    subject do
      described_class
        .output(
          logger: ::Kitchen::Logger.new,
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .no_color,
          timeout: 1234,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "output -no-color"
    )
  end

  describe ".plan" do
    subject do
      described_class
        .plan(
          logger: ::Kitchen::Logger.new,
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .no_color,
          timeout: 1234,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "plan -no-color"
    )
  end

  describe ".validate" do
    subject do
      described_class
        .validate(
          logger: ::Kitchen::Logger.new,
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .no_color,
          timeout: 1234,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "validate -no-color"
    )
  end

  describe ".version" do
    subject do
      described_class
        .version(
          logger: ::Kitchen::Logger.new,
          working_directory: "working_directory"
        )
    end

    it_behaves_like(
      "a command is run",
       subcommand: "version"
    )
  end
end
