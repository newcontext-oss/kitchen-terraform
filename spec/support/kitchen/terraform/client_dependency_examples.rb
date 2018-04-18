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

require "kitchen/terraform/client_dependency"

::RSpec
  .shared_examples "Kitchen::Terraform::ClientDependency" do
    describe "#finalize_config!" do
      def expect_invoking_method
        expect do
          subject.finalize_config! instance
        end
      end

      context "when `terraform version` results in failure" do
        before do
          allow(client).to receive(:if_version_not_supported).and_yield message: "mocked `terraform version` failure"
        end

        specify do
          expect_invoking_method
            .to(
              raise_error(
                ::Kitchen::ClientError,
                "mocked `terraform version` failure"
              )
            )
        end
      end

      context "when `terraform version` results in success" do
        specify do
          expect_invoking_method.to_not raise_error
        end
      end
    end
  end
