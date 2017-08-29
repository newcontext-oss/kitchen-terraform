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

::RSpec.shared_context "Kitchen::Terraform::Client::Command" do |shell_out_wrapper:, subcommand:|
  before do |example|
    allow(::Mixlib::ShellOut)
      .to(
        receive(:new)
          .with(
            /terraform #{subcommand}/,
            any_args
          )
          .and_wrap_original do |original, *arguments|
            original
              .call(*arguments)
              .tap do |shell_out|
                example
                  .instance_exec(
                    shell_out: shell_out,
                    &shell_out_wrapper
                  )
              end
          end
      )
  end
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command error failure" do |error:, subcommand:|
  include_context(
    "Kitchen::Terraform::Client::Command",
    shell_out_wrapper: lambda do |shell_out:|
      allow(shell_out)
        .to(
          receive(:run_command)
            .and_raise(
              error,
              "mocked error"
            )
        )
    end,
    subcommand: subcommand,
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command status failure" do |subcommand:|
  include_context(
    "Kitchen::Terraform::Client::Command",
    shell_out_wrapper: lambda do |shell_out:|
      allow(shell_out).to receive(:exitstatus).and_return 1

      allow(shell_out).to receive(:run_command).and_return shell_out

      allow(shell_out).to receive(:stderr).and_return "stderr"

      allow(shell_out).to receive(:stdout).and_return "stdout"
    end,
    subcommand: subcommand
  )
end

::RSpec.shared_context(
  "Kitchen::Terraform::Client::Command success"
) do |output_contents: "output_contents", subcommand:|
  include_context(
    "Kitchen::Terraform::Client::Command",
    shell_out_wrapper: lambda do |shell_out:|
      allow(shell_out).to receive(:exitstatus).and_return 0

      allow(shell_out).to receive(:run_command).and_return shell_out

      allow(shell_out).to receive(:stdout).and_return output_contents
    end,
    subcommand: subcommand
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.apply failure" do
  include_context(
    "Kitchen::Terraform::Client::Command status failure",
    subcommand: /apply/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.apply success" do
  include_context(
    "Kitchen::Terraform::Client::Command success",
    subcommand: /apply/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.destroy failure" do
  include_context(
    "Kitchen::Terraform::Client::Command status failure",
    subcommand: /destroy/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.destroy success" do
  include_context(
    "Kitchen::Terraform::Client::Command success",
    subcommand: /destroy/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.init failure" do
  include_context(
    "Kitchen::Terraform::Client::Command status failure",
    subcommand: /init/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.init success" do
  include_context(
    "Kitchen::Terraform::Client::Command success",
    subcommand: /init/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.output failure" do
  include_context(
    "Kitchen::Terraform::Client::Command status failure",
    subcommand: /output/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.output success" do |output_contents: "output_contents"|
  include_context(
    "Kitchen::Terraform::Client::Command success",
    output_contents: output_contents,
    subcommand: /output/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.validate failure" do
  include_context(
    "Kitchen::Terraform::Client::Command status failure",
    subcommand: /validate/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.validate success" do
  include_context(
    "Kitchen::Terraform::Client::Command success",
    subcommand: /validate/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.version failure" do
  include_context(
    "Kitchen::Terraform::Client::Command status failure",
    subcommand: /version/
  )
end

::RSpec.shared_context "Kitchen::Terraform::Client::Command.version success" do |output_contents: "output_contents"|
  include_context(
    "Kitchen::Terraform::Client::Command success",
    output_contents: output_contents,
    subcommand: /version/
  )
end
