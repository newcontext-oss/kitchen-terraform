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

require "mixlib/shellout"

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.apply failure" do
    include_context(
      "Kitchen::Terraform::Client::Command.create failure",
      subcommand: "apply"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.apply success" do
    include_context(
      "Kitchen::Terraform::Client::Command.create success",
      subcommand: "apply"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.destroy failure" do
    include_context(
      "Kitchen::Terraform::Client::Command.create failure",
      subcommand: "destroy"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.destroy success" do
    include_context(
      "Kitchen::Terraform::Client::Command.create success",
      subcommand: "destroy"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.init failure" do
    include_context(
      "Kitchen::Terraform::Client::Command.create failure",
      subcommand: "init"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.init success" do
    include_context(
      "Kitchen::Terraform::Client::Command.create success",
      subcommand: "init"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.output failure" do
    include_context(
      "Kitchen::Terraform::Client::Command.create failure",
      subcommand: "output"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.output success" do |output: "output"|
    include_context(
      "Kitchen::Terraform::Client::Command.create success",
      output: output,
      subcommand: "output"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.run error failure" do |error:|
    before do
      allow(shell_out)
        .to(
          receive(:run_command)
            .and_raise(
              error,
              "mocked error"
            )
        )
    end
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.run status failure" do
    before do
      allow(shell_out).to receive(:exitstatus).and_return 1

      allow(shell_out).to receive(:run_command).and_return shell_out

      allow(shell_out).to receive(:stderr).and_return "stderr"

      allow(shell_out).to receive(:stdout).and_return "stdout"
    end
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.run success" do |output: "output"|
    before do
      allow(shell_out).to receive(:exitstatus).and_return 0

      allow(shell_out).to receive(:run_command).and_return shell_out

      allow(shell_out).to receive(:stdout).and_return output
    end
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.validate failure" do
    include_context(
      "Kitchen::Terraform::Client::Command.create failure",
      subcommand: "validate"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.validate success" do
    include_context(
      "Kitchen::Terraform::Client::Command.create success",
      subcommand: "validate"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.version failure" do
    include_context(
      "Kitchen::Terraform::Client::Command.create failure",
      subcommand: "version"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.version success" do |output: "output"|
    include_context(
      "Kitchen::Terraform::Client::Command.create success",
      output: output,
      subcommand: "version"
    )
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.create failure" do |subcommand:|
    before do
      allow(::Mixlib::ShellOut)
        .to(
          receive(:new)
            .with(
              /#{subcommand}/,
              any_args
            )
            .and_raise(
              ::Mixlib::ShellOut::InvalidCommandOption,
              "invalid command option"
            )
        )
    end
  end

::RSpec
  .shared_context "Kitchen::Terraform::Client::Command.create success" do |output: "output", subcommand:|
    before do
      allow(::Mixlib::ShellOut)
        .to(
          receive(:new)
            .with(
              /#{subcommand}/,
              any_args
            )
            .and_wrap_original do |original, *arguments|
              original
                .call(*arguments)
                .tap do |shell_out|
                  allow(shell_out).to receive(:exitstatus).and_return 0

                  allow(shell_out).to receive :run_command

                  allow(shell_out).to receive(:stdout).and_return output
                end
            end
        )
    end
  end
