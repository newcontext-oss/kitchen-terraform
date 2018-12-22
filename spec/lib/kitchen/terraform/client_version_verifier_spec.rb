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

require "kitchen/terraform/client_version_verifier"
require "kitchen/terraform/command/version"

::RSpec.describe ::Kitchen::Terraform::ClientVersionVerifier do
  describe "#verify" do
    shared_examples "the version is unsupported" do
      specify "should result in failure with a message which provides a remedy for the lack of support" do
        expect do
          subject.verify version: version
        end.to result_in_failure.with_message "Terraform v#{version} is not supported; install Terraform ~> v0.11.4"
      end
    end

    shared_examples "the version is supported" do
      specify "should result in success with a message indicating support" do
        expect do
          subject.verify version: version
        end.to result_in_success.with_message "Terraform v#{version} is supported"
      end
    end

    context "when the version is 0.11.3" do
      it_behaves_like "the version is unsupported" do
        let :version do
          ::Kitchen::Terraform::Command::Version.new "Terraform v0.11.3"
        end
      end
    end

    context "when the version is 0.11.4" do
      it_behaves_like "the version is supported" do
        let :version do
          ::Kitchen::Terraform::Command::Version.new "Terraform v0.11.4"
        end
      end
    end

    context "when the version is 0.12.0" do
      it_behaves_like "the version is unsupported" do
        let :version do
          ::Kitchen::Terraform::Command::Version.new "Terraform v0.12.0"
        end
      end
    end
  end
end
