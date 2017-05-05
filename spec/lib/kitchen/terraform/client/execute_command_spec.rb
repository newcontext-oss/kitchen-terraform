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
  describe "#call" do
    let :shell_out do instance_double ::Mixlib::ShellOut end

    describe "executing" do
      before do allow(shell_out).to receive(:error!).with no_args end

      after do described_class.call shell_out: shell_out end

      subject do shell_out end

      it "runs the shell out command" do is_expected.to receive(:run_command).with no_args end
    end

    describe "error handling" do
      subject do proc do described_class.call shell_out: shell_out end end

      context "when an error occurs during execution" do
        shared_examples "an expected error has occurred" do
          before do
            allow(shell_out).to receive(:run_command).with no_args

            allow(shell_out).to receive(:error!).with(no_args).and_raise error

            allow(shell_out).to receive(:command).with(no_args).and_return "command"
          end

          it "raises a standard error" do
            is_expected.to raise_error ::Kitchen::StandardError, /`command` failed: '.+'/
          end
        end

        context "when the error is due to incorrect permissions" do
          it_behaves_like "an expected error has occurred" do let :error do ::Errno::EACCES end end
        end

        context "when the error is due to a missing file" do
          it_behaves_like "an expected error has occurred" do let :error do ::Errno::ENOENT end end
        end

        context "when the error is due to a command timeout" do
          it_behaves_like "an expected error has occurred" do let :error do ::Mixlib::ShellOut::CommandTimeout end end
        end

        context "when the error is due to a failed shell out command" do
          it_behaves_like "an expected error has occurred" do
            let :error do ::Mixlib::ShellOut::ShellCommandFailed end
          end
        end
      end
    end
  end
end
