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
require "kitchen/terraform/shell_out"
require "mixlib/shellout"

::RSpec.describe ::Kitchen::Terraform::ShellOut do
  describe ".run" do
    let :complete_environment do
      { "TF_IN_AUTOMATION" => "true", "TF_WARN_OUTPUT_ERRORS" => "1", "FOO" => "bar" }
    end

    let :duration do
      1234
    end

    let :extra_environment do
      { "FOO" => "bar" }
    end

    let :logger do
      ::Kitchen::Logger.new
    end

    context "when an invalid command option is sent to the shell out constructor" do
      before do
        allow(::Mixlib::ShellOut).to(
          receive(:new).with(
            "client command",
            cwd: "/working/directory",
            environment: complete_environment,
            live_stream: logger,
            timeout: duration,
          ).and_raise(::Mixlib::ShellOut::InvalidCommandOption, "invalid command option")
        )
      end

      specify "should raise an error with the invalid command option error message" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message matching "invalid command option"
      end
    end

    shared_context "when an error occurs" do
      def mock_run_command(original, *arguments)
        original.call(*arguments).tap do |shell_out|
          allow(shell_out).to receive(:run_command).and_raise error_class, "mocked error"
        end
      end

      let :new_arguments do
        [
          "client command",
          {
            cwd: "/working/directory",
            environment: complete_environment,
            live_stream: logger,
            timeout: duration,
          },
        ]
      end

      before do
        allow(::Mixlib::ShellOut).to receive(:new).with(*new_arguments).and_wrap_original(&method(:mock_run_command))
      end
    end

    context "when a permissions error occurs" do
      include_context "when an error occurs"

      let :error_class do
        ::Errno::EACCES
      end

      specify "should raise an error with the permissions error message" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message "Running command resulted in failure: Permission denied - mocked error"
      end
    end

    context "when an entry error occurs" do
      include_context "when an error occurs"

      let :error_class do
        ::Errno::ENOENT
      end

      specify "should raise an error with the entry error message" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message(
          "Running command resulted in failure: No such file or directory - mocked error"
        )
      end
    end

    context "when a timeout error occurs" do
      include_context "when an error occurs"

      let :error_class do
        ::Mixlib::ShellOut::CommandTimeout
      end

      specify "should raise an error with the timeout error message" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message "Running command resulted in failure: mocked error"
      end
    end

    context "when the command exits with a nonzero value" do
      before do
        allow(::Mixlib::ShellOut).to(
          receive(:new).with(
            "client command",
            cwd: "/working/directory",
            environment: complete_environment,
            live_stream: logger,
            timeout: duration,
          ).and_wrap_original do |original, *arguments|
            original.call(*arguments).tap do |shell_out|
              allow(shell_out).to receive(:exitstatus).and_return 1
              allow(shell_out).to receive(:run_command).and_return shell_out
              allow(shell_out).to receive(:stderr).and_return "stderr"
              allow(shell_out).to receive(:stdout).and_return "stdout"
            end
          end
        )
      end

      specify "should raise an error with the nonzero value message" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message(
          matching("Running command resulted in failure: Expected process to exit with \\[0\\], but received '1'")
        )
      end

      specify "should raise an error with the stdout" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message matching "stdout"
      end

      specify "should raise an error with the stderr" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_failure.with_message matching "stderr"
      end
    end

    context "when the command exits with a zero value" do
      before do
        allow(::Mixlib::ShellOut).to(
          receive(:new).with(
            "client command",
            cwd: "/working/directory",
            environment: complete_environment,
            live_stream: logger,
            timeout: duration,
          ).and_wrap_original do |original, *arguments|
            original.call(*arguments).tap do |shell_out|
              allow(shell_out).to receive(:exitstatus).and_return 0
              allow(shell_out).to receive(:run_command).and_return shell_out
              allow(shell_out).to receive(:stdout).and_return "stdout"
            end
          end
        )
      end

      specify "should yield the stdout" do
        expect do
          described_class.run(
            client: "client",
            command: "command",
            options: {
              cwd: "/working/directory",
              environment: extra_environment,
              live_stream: logger,
              timeout: duration,
            },
          )
        end.to result_in_success.with_message "stdout"
      end
    end
  end
end
