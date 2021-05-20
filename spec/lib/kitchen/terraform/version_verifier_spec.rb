# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "kitchen/terraform/unsupported_client_version_error"
require "kitchen/terraform/version_verifier"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::VersionVerifier do
  subject do
    described_class.new version_requirement: version_requirement
  end

  let :version_requirement do
    ::Gem::Requirement.new "~> 1.2.3"
  end

  describe "#verify" do
    context "when the version does not meet the requirement" do
      let :version do
        ::Gem::Version.new "0.1.2"
      end

      specify "should raise an error" do
        expect do
          subject.verify version: version
        end.to raise_error(
          ::Kitchen::Terraform::UnsupportedClientVersionError,
          "The Terraform client version is unsupported."
        )
      end
    end

    context "when the version does meet the requirement" do
      let :version do
        ::Gem::Version.new "1.2.4"
      end

      specify "should not raise an error" do
        expect do
          subject.verify version: version
        end.not_to raise_error
      end
    end
  end
end
