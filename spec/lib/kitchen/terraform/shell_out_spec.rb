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
require "kitchen/terraform/shell_out"
require "mixlib/shellout"

::RSpec
  .describe ::Kitchen::Terraform::ShellOut do
    describe ".run" do
      subject do
        proc do
          described_class
            .run(
              command: "command",
              duration: duration,
              logger: logger,
              working_directory: "/working/directory"
            )
        end
      end

      let :duration do
        1234
      end

      let :environment do
        {"TF_IN_AUTOMATION" => "true"}
      end

      let :logger do
        ::Kitchen::Logger.new
      end

      context "when an invalid command option is sent to the shell out constructor" do
        before do
          allow(::Mixlib::ShellOut)
            .to(
              receive(:new)
                .with(
                  "terraform command",
                  cwd: "/working/directory",
                  environment: environment,
                  live_stream: logger,
                  timeout: duration
                )
                .and_raise(
                  ::Mixlib::ShellOut::InvalidCommandOption,
                  "invalid command option"
                )
            )
        end

        it do
          is_expected.to result_in_failure.with_message matching "invalid command option"
        end
      end

      shared_context "when an error occurs" do
        before do
          allow(::Mixlib::ShellOut)
            .to(
              receive(:new)
                .with(
                  "terraform command",
                  cwd: "/working/directory",
                  environment: environment,
                  live_stream: logger,
                  timeout: duration
                )
                .and_wrap_original do |original, *arguments|
                  original
                    .call(*arguments)
                    .tap do |shell_out|
                      allow(shell_out)
                        .to(
                          receive(:run_command)
                            .and_raise(
                              error_class,
                              "mocked error"
                            )
                        )
                    end
                end
            )
        end
      end

      context "when a permissions error occurs" do
        include_context "when an error occurs"

        let :error_class do
          ::Errno::EACCES
        end

        it do
          is_expected
            .to result_in_failure.with_message "Running command resulted in failure: Permission denied - mocked error"
        end
      end

      context "when an entry error occurs" do
        include_context "when an error occurs"

        let :error_class do
          ::Errno::ENOENT
        end

        it do
          is_expected
            .to(
              result_in_failure
                .with_message("Running command resulted in failure: No such file or directory - mocked error")
            )
        end
      end

      context "when a timeout error occurs" do
        include_context "when an error occurs"

        let :error_class do
          ::Mixlib::ShellOut::CommandTimeout
        end

        it do
          is_expected.to result_in_failure.with_message "Running command resulted in failure: mocked error"
        end
      end

      context "when the command exits with a nonzero value" do
        before do
          allow(::Mixlib::ShellOut)
            .to(
              receive(:new)
                .with(
                  "terraform command",
                  cwd: "/working/directory",
                  environment: environment,
                  live_stream: logger,
                  timeout: duration
                )
                .and_wrap_original do |original, *arguments|
                  original
                    .call(*arguments)
                    .tap do |shell_out|
                      allow(shell_out).to receive(:exitstatus).and_return 1

                      allow(shell_out).to receive(:run_command).and_return shell_out

                      allow(shell_out).to receive(:stderr).and_return "stderr"

                      allow(shell_out).to receive(:stdout).and_return "stdout"
                    end
                end
            )
        end

        it do
          is_expected
            .to(
              result_in_failure
                .with_message(
                  matching(
                    "Running command resulted in failure: Expected process to exit with \\[0\\], but received '1'"
                  )
                )
            )
        end

        it do
          is_expected.to result_in_failure.with_message matching "stdout"
        end

        it do
          is_expected.to result_in_failure.with_message matching "stderr"
        end
      end

      context "when the command exits with a zero value" do
        before do
          allow(::Mixlib::ShellOut)
            .to(
              receive(:new)
                .with(
                  "terraform command",
                  cwd: "/working/directory",
                  environment: environment,
                  live_stream: logger,
                  timeout: duration
                )
                .and_wrap_original do |original, *arguments|
                  original
                    .call(*arguments)
                    .tap do |shell_out|
                      allow(shell_out).to receive(:exitstatus).and_return 0

                      allow(shell_out).to receive(:run_command).and_return shell_out

                      allow(shell_out).to receive(:stdout).and_return "stdout"
                    end
                end
            )
        end

        it do
          is_expected.to result_in_success.with_message "stdout"
        end
      end
    end
  end
