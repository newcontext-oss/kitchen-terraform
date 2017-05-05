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
require "kitchen/driver/terraform"
require "kitchen/terraform/client/version"
require "support/raise_error_examples"
require "support/kitchen/instance_context"
require "support/terraform/configurable_context"
require "support/terraform/configurable_examples"
require "terraform/configurable"

::RSpec.describe ::Kitchen::Driver::Terraform do
  let :described_instance do driver end

  it_behaves_like ::Terraform::Configurable do include_context "instance" end

  describe ".serial_actions" do
    include_context "instance"

    subject :serial_actions do described_class.serial_actions end

    it "is empty" do is_expected.to be_empty end
  end

  describe "#destroy" do
    include_context "client"

    include_context "instance"

    include_context "silent_client"

    let :allow_load_state do allow(silent_client).to receive(:load_state).with no_args end

    context "when a state does exist" do
      before do allow_load_state.and_yield end

      after do described_instance.destroy end

      subject do client end

      it "applies destructively" do is_expected.to receive(:apply_destructively).with no_args end
    end

    context "when a state does not exist" do
      before do allow_load_state.and_raise ::Errno::ENOENT, "state file" end

      after do described_instance.destroy end

      subject do described_instance end

      it "logs a debug message" do is_expected.to receive(:debug).with(/state file/) end
    end

    context "when a command fails" do
      before do allow_load_state.and_raise ::SystemCallError, "system call" end

      subject do proc do described_instance.destroy end end

      it "raises an action failed error" do is_expected.to raise_error ::Kitchen::ActionFailed, /system call/ end
    end
  end

  describe "#verify_dependencies" do
    include_context "instance"

    before do
      allow(::Kitchen::Terraform::Client::Version).to receive(:call)
        .with(cli: described_instance[:cli], logger: described_instance.debug_logger).and_yield version: version
    end

    context "when the client version is deprecated" do
      let :version do 0.7 end

      after do described_instance.verify_dependencies end

      subject do logger end

      it "logs a warning message" do is_expected.to receive(:warn).with kind_of ::String end
    end

    context "when the client version is invalid" do
      let :version do 1.0 end

      subject do proc do described_instance.verify_dependencies end end

      it "raises a user error" do is_expected.to raise_error ::Kitchen::UserError end
    end
  end
end
