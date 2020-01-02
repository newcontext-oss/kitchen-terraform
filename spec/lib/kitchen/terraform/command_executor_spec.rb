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
require "mixlib/shellout"

::RSpec.describe ::Kitchen::Terraform::CommandExecutor do
  describe "#run" do
    subject do
      described_class.new client: client, logger: logger
    end

    let :client do
      "client"
    end

    let :client_with_command do
      "client command"
    end

    let :command do
      "command"
    end

    let :environment do
      { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true", "TF_WARN_OUTPUT_ERRORS" => "1" }
    end

    let :timeout do
      1234
    end

    let :logger do
      ::Kitchen::Logger.new
    end

    let :working_directory do
      "/working-directory"
    end

    shared_context "when an error occurs" do
      def mock_run_command(original, *arguments)
        original.call(*arguments).tap do |shell_out|
          allow(shell_out).to receive(:run_command).and_raise error_class, "mocked error"
        end
      end

      let :new_arguments do
        [
          client_with_command,
          {
            cwd: working_directory,
            environment: environment,
            live_stream: logger,
            timeout: timeout,
          },
        ]
      end

      before do
        allow(::Mixlib::ShellOut).to receive(:new).with(*new_arguments).and_wrap_original(&method(:mock_run_command))
      end
    end

    context "when running the command fails due to unauthorized access to a file or directory" do
      include_context "when an error occurs"

      let :error_class do
        ::Errno::EACCES
      end

      specify "should raise a transient failure error" do
        expect do
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
          )
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when an entry error occurs" do
      include_context "when an error occurs"

      let :error_class do
        ::Errno::ENOENT
      end

      specify "should raise an error with the entry error message" do
        expect do
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
          )
        end.to raise_error ::Kitchen::TransientFailure, "Failed running command `client command`."
      end
    end

    context "when a timeout error occurs" do
      include_context "when an error occurs"

      let :error_class do
        ::Mixlib::ShellOut::CommandTimeout
      end

      specify "should raise an error with the timeout error message" do
        expect do
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
          )
        end.to raise_error ::Kitchen::TransientFailure, "Failed running command `client command`."
      end
    end

    context "when the command exits with a nonzero value" do
      before do
        allow(::Mixlib::ShellOut).to(
          receive(:new).with(
            client_with_command,
            cwd: working_directory,
            environment: environment,
            live_stream: logger,
            timeout: timeout,
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
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
          )
        end.to raise_error ::Kitchen::TransientFailure, "Failed running command `client command`:\n\tstderr"
      end

      specify "should raise an error with the stdout" do
        expect do
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
          )
        end.to raise_error ::Kitchen::TransientFailure, "Failed running command `client command`:\n\tstderr"
      end

      specify "should raise an error with the stderr" do
        expect do
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
          )
        end.to raise_error ::Kitchen::TransientFailure, "Failed running command `client command`:\n\tstderr"
      end
    end

    context "when the command exits with a zero value" do
      before do
        allow(::Mixlib::ShellOut).to(
          receive(:new).with(
            client_with_command,
            cwd: working_directory,
            environment: environment,
            live_stream: logger,
            timeout: timeout,
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
        expect do |block|
          subject.run(
            command: command,
            options: {
              cwd: working_directory,
              timeout: timeout,
            },
            &block
          )
        end.to yield_with_args standard_output: "stdout"
      end
    end
  end
end
