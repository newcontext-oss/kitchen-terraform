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
require "support/dry/monads/either_matchers"

::RSpec
  .describe ::Kitchen::Terraform::ClientVersionVerifier do
    describe "#verify" do
      subject do
        described_class
          .new
          .verify(version_output: "Terraform v#{version}")
      end

      shared_examples "the version is unsupported" do
        it do
          is_expected
            .to(
              result_in_failure
                .with_the_value("Terraform v#{version} is not supported; install Terraform ~> v0.10.2")
            )
        end
      end

      shared_examples "the version is supported" do
        it do
          is_expected.to result_in_success.with_the_value "Terraform v#{version} is supported"
        end
      end

      context "when the version is 0.10.2" do
        it_behaves_like "the version is supported" do
          let :version do
            "0.10.2"
          end
        end
      end

      context "when the version is 0.10.3" do
        it_behaves_like "the version is supported" do
          let :version do
            "0.10.3"
          end
        end
      end

      context "when the version is 0.10.1" do
        it_behaves_like "the version is unsupported" do
          let :version do
            "0.10.1"
          end
        end
      end

      context "when the version is 0.11.0" do
        it_behaves_like "the version is unsupported" do
          let :version do
            "0.11.0"
          end
        end
      end
    end
  end
