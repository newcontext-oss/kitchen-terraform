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

require "kitchen/driver/terraform"
require "support/raise_error_examples"
require "support/kitchen/instance_context"
require "support/terraform/configurable_context"
require "support/terraform/configurable_examples"

::RSpec.describe ::Kitchen::Driver::Terraform do
  it_behaves_like ::Terraform::Configurable do
    include_context "instance"

    let :described_instance do driver end
  end

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

    let :described_instance do driver end

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
    include_context "client"

    include_context "instance"

    let :described_instance do driver end

    before do
      allow(::Terraform::Client).to receive(:new).with(config: driver, logger: duck_type(:<<)).and_return client

      allow(client).to receive(:version).with(no_args).and_return ::Terraform::Version.create value: version
    end

    context "when the Terraform version is not supported" do
      let :version do "0.10" end

      it_behaves_like "a user error has occurred" do
        let :described_method do described_instance.verify_dependencies end

        let :message do "Terraform v0.10 is not supported\nInstall Terraform v0.9" end
      end
    end

    context "when the Terraform version is deprecated" do
      let :version do "0.6" end

      after do described_instance.verify_dependencies end

      subject do described_instance end

      it "logs a deprecation" do
        is_expected.to receive(:log_deprecation).with aspect: "Terraform v0.6", remediation: "Install Terraform v0.9"
      end
    end
  end
end
