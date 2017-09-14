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

require "kitchen"
require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options"
require "mixlib/shellout"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Command do
  shared_examples "a command is created" do |subcommand:|
    subject do
      described_class
        .send(
          subcommand,
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .no_color,
          working_directory: "working_directory"
        )
    end

    context "when an invalid command option is sent to the shell out constructor" do
      include_context(
        "Kitchen::Terraform::Client::Command.create failure",
        subcommand: subcommand
      )

      it do
        is_expected.to result_in_failure.with_the_value matching "invalid command option"
      end
    end

    context "when no invalid command option is sent to the shell out constructor" do
      it do
        is_expected
          .to(
            result_in_success do |value|
              "terraform #{subcommand} -no-color" == value.command
            end
          )
      end
    end
  end

  describe ".apply" do
    it_behaves_like(
      "a command is created",
      subcommand: "apply"
    )
  end

  describe ".destroy" do
    it_behaves_like(
      "a command is created",
      subcommand: "destroy"
    )
  end

  describe ".init" do
    it_behaves_like(
      "a command is created",
      subcommand: "init"
    )
  end

  describe ".output" do
    it_behaves_like(
      "a command is created",
      subcommand: "output"
    )
  end

  describe ".run" do
    let :shell_out do
      described_class
        .apply(
          options: ::Kitchen::Terraform::Client::Options.new,
          working_directory: "working_directory"
        ).value
    end

    subject do
      described_class
        .run(
          logger: ::Kitchen::Logger.new,
          shell_out: shell_out,
          timeout: 1234
        )
    end

    context "when a permissions error occurs" do
      include_context(
        "Kitchen::Terraform::Client::Command.run error failure",
        error: ::Errno::EACCES
      )

      it do
        is_expected.to result_in_failure.with_the_value "Permission denied - mocked error"
      end
    end

    context "when an entry error occurs" do
      include_context(
        "Kitchen::Terraform::Client::Command.run error failure",
        error: ::Errno::ENOENT
      )

      it do
        is_expected.to result_in_failure.with_the_value "No such file or directory - mocked error"
      end
    end

    context "when a timeout error occurs" do
      include_context(
        "Kitchen::Terraform::Client::Command.run error failure",
        error: ::Mixlib::ShellOut::CommandTimeout
      )

      it do
        is_expected.to result_in_failure.with_the_value "mocked error"
      end
    end

    context "when the command exits with a nonzero value" do
      include_context "Kitchen::Terraform::Client::Command.run status failure"

      it do
        is_expected.to result_in_failure.with_the_value matching "Expected process to exit with \\[0\\]"
      end
    end

    context "when the command exits with a zero value" do
      include_context "Kitchen::Terraform::Client::Command.run success"

      it do
        is_expected.to result_in_success.with_the_value "output"
      end
    end
  end

  describe ".validate" do
    it_behaves_like(
      "a command is created",
      subcommand: "validate"
    )
  end

  describe ".version" do
    it_behaves_like(
      "a command is created",
      subcommand: "version"
    )
  end
end
