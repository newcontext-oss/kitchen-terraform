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

require "kitchen/terraform/client/version"

::RSpec.describe ::Kitchen::Terraform::Client::Version do
  describe ".call" do
    let :cli do "cli" end

    let :logger do instance_double ::Object end

    let :shell_out do instance_double ::Mixlib::ShellOut end

    let :stdout do
      "Terraform v0.9.3\n\nYour version of Terraform is out of date! The latest version is 0.9.4. You can update by " \
        "downloading from www.terraform.io"
    end

    let :timeout do instance_double ::Object end

    before do
      allow(::Mixlib::ShellOut)
        .to receive(:new).with(cli, "version", live_stream: logger, timeout: timeout).and_return shell_out

      allow(::Kitchen::Terraform::Client::ExecuteCommand).to receive(:call).with shell_out: shell_out

      allow(shell_out).to receive(:stdout).and_return stdout
    end

    describe "the shell out command" do
      after do described_class.call cli: cli, logger: logger, timeout: timeout do end end

      subject do ::Kitchen::Terraform::Client::ExecuteCommand end

      it "is executed" do is_expected.to receive(:call).with shell_out: shell_out end
    end

    describe "the version value" do
      subject do lambda do |block| described_class.call cli: cli, logger: logger, timeout: timeout, &block end end

      it "is yielded" do is_expected.to yield_with_args version: 0.9 end
    end
  end
end
