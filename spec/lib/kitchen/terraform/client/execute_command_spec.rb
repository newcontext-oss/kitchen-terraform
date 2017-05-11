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

require "kitchen/terraform/client/execute_command"

::RSpec.describe ::Kitchen::Terraform::Client::ExecuteCommand do
  describe ".call" do
    let :shell_out do
      instance_double ::Mixlib::ShellOut
    end

    before do
      allow(::Mixlib::ShellOut).to receive(:new)
        .with("cli", "command", "-no-color", "target", live_stream: "logger", timeout: "timeout").and_return shell_out

      allow(shell_out).to receive(:run_command).with no_args
    end

    context "when the execution is a failure" do
      context "when an error occurs during execution" do
        shared_examples "an expected error has occurred" do
          before do
            allow(shell_out).to receive(:error!).with(no_args).and_raise error

            allow(shell_out).to receive(:command).with(no_args).and_return "command"
          end

          subject do
            catch :failure do
              described_class.call command: "command", config: {apply_timeout: "timeout", cli: "cli"}, logger: "logger",
                                   options: {color: false}, target: "target"
            end
          end

          it "throws :failure with a string describing the execution failure" do
            is_expected.to match /`command` failed: '.+'/
          end
        end

        context "when the error is due to incorrect permissions" do
          it_behaves_like "an expected error has occurred" do
            let :error do
              ::Errno::EACCES
            end
          end
        end

        context "when the error is due to a missing file" do
          it_behaves_like "an expected error has occurred" do
            let :error do
              ::Errno::ENOENT
            end
          end
        end

        context "when the error is due to a command timeout" do
          it_behaves_like "an expected error has occurred" do
            let :error do
              ::Mixlib::ShellOut::CommandTimeout
            end
          end
        end

        context "when the error is due to a failed shell out command" do
          it_behaves_like "an expected error has occurred" do
            let :error do
              ::Mixlib::ShellOut::ShellCommandFailed
            end
          end
        end
      end
    end

    context "when the execution is a success" do
      before do
        allow(shell_out).to receive(:error!).with no_args

        allow(shell_out).to receive(:stdout).with(no_args).and_return "stdout"
      end

      subject do
        catch :success do
          described_class.call command: "command", config: {apply_timeout: "timeout", cli: "cli"}, logger: "logger",
                               options: {color: false}, target: "target"
        end
      end

      it "throws :success with a string containing the standard output" do
        is_expected.to eq "stdout"
      end
    end
  end
end
