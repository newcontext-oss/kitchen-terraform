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

::RSpec.shared_context(
  "Kitchen::Terraform::Client::ExecuteCommand"
) do |command:, error: false, error_class: ::Mixlib::ShellOut::CommandTimeout, exit_code: 1, output: ""|
  before do
    allow(::Mixlib::ShellOut).to receive(:new).with(/^\w+ #{command}/, any_args).and_wrap_original do |new, *arguments|
      new.call(*arguments).tap do |shell_out|
        allow(shell_out).to receive(:run_command) do
          error and raise error_class, "mocked `#{shell_out.command}` error"
          shell_out
        end

        allow(shell_out).to receive(:exitstatus).and_return exit_code

        allow(shell_out).to receive :stdout do
          output.empty? and "mocked `#{shell_out.command}` output" or output
        end
      end
    end
  end
end
