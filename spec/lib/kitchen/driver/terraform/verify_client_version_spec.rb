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

require "kitchen/driver/terraform/verify_client_version"
require "terraform/client"

::RSpec.describe ::Kitchen::Driver::Terraform::VerifyClientVersion do
  describe ".call" do
    let :call do described_class.call client: client, logger: logger end

    let :client do instance_double ::Terraform::Client end

    let :logger do instance_double ::Kitchen::Logger end

    before do
      allow(client).to receive(:version).with(no_args).and_return version

      allow(logger).to receive(:warn).with kind_of ::String
    end

    shared_examples "a deprecated version is detected" do
      after do call end

      subject do logger end

      it "logs a warning" do is_expected.to receive(:warn).with message end
    end

    shared_examples "a valid version is detected" do
      subject do proc do call end end

      it "raises no error" do is_expected.to_not raise_error end
    end

    shared_examples "an invalid version is detected" do
      subject do proc do call end end

      it "raises a user error" do is_expected.to raise_error ::Kitchen::UserError, message end
    end

    context "when the client version is 0.10" do
      let :version do "0.10.0" end

      it_behaves_like "an invalid version is detected" do
        let :message do
          "Terraform version 0.10.0 is not supported; supported Terraform versions are 0.7 through 0.9"
        end
      end
    end

    context "when the client version is 0.9" do
      let :version do "0.9.0" end

      it_behaves_like "a valid version is detected"
    end

    context "when the client version is 0.8" do
      let :version do "0.8.0" end

      it_behaves_like "a valid version is detected"

      it_behaves_like "a deprecated version is detected" do
        let :message do
          "Support for Terraform version 0.8.0 is deprecated and will be dropped in kitchen-terraform version 2.0; " \
            "upgrade to Terraform version 0.9"
        end
      end
    end

    context "when the client version is 0.7" do
      let :version do "0.7.0" end

      it_behaves_like "a valid version is detected"

      it_behaves_like "a deprecated version is detected" do
        let :message do
          "Support for Terraform version 0.7.0 is deprecated and will be dropped in kitchen-terraform version 2.0; " \
            "upgrade to Terraform version 0.9"
        end
      end
    end

    context "when the client version is 0.6" do
      let :version do "0.6.0" end

      it_behaves_like "an invalid version is detected" do
        let :message do "Terraform version 0.6.0 is not supported; supported Terraform versions are 0.7 through 0.9" end
      end
    end
  end
end
