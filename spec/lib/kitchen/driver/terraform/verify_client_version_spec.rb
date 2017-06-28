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
require "support/dry/monads/either_matchers"

::RSpec.describe ::Kitchen::Driver::Terraform::VerifyClientVersion do
  describe ".call" do
    shared_examples "the version is deprecated" do |version:|
      subject do
        described_class.call version: version
      end

      it do
        is_expected.to result_in_success
          .with_the_value "Terraform version #{version} is deprecated and will not be supported by kitchen-terraform " \
                          "version 2.0; upgrade to Terraform version 0.9 to remain supported"
      end
    end

    shared_examples "the version is unsupported" do |version:|
      subject do
        described_class.call version: version
      end

      it do
        is_expected.to result_in_failure
          .with_the_value "Terraform version #{version} is not supported; supported Terraform versions are 0.7 " \
                            "through 0.9"
      end
    end

    shared_examples "the version is supported" do |version:|
      subject do
        described_class.call version: version
      end

      it do
        is_expected.to result_in_success.with_the_value "Terraform version #{version} is supported"
      end
    end

    context "when the version is 0.10" do
      it_behaves_like "the version is unsupported", version: 0.10
    end

    context "when the version is 0.9" do
      it_behaves_like "the version is supported", version: 0.9
    end

    context "when the version is 0.8" do
      it_behaves_like "the version is deprecated", version: 0.8
    end

    context "when the version is 0.7" do
      it_behaves_like "the version is deprecated", version: 0.7
    end

    context "when the version is 0.6" do
      it_behaves_like "the version is unsupported", version: 0.6
    end
  end
end
