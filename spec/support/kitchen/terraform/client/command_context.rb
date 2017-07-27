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
  "Kitchen::Terraform::Client::Command"
) do |exit_code: 1, error: nil, output_contents: "stdout", subcommand:|
  before do
  allow(::Mixlib::ShellOut).to receive(:new).with(/^\w+ #{subcommand}/, any_args)
    .and_wrap_original do |method, *arguments|
      method.call(*arguments).tap do |shell_out|
        allow(shell_out).to receive(:exitstatus).and_return exit_code

        allow(shell_out).to receive(:run_command) do
          raise error, "mocked `#{shell_out.command}` error" if not error.nil?
          shell_out
        end

        allow(shell_out).to receive(:stdout).and_return output_contents
      end
    end
  end
end
