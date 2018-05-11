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

require "kitchen/terraform/breaking/kitchen_instance"
require "kitchen/terraform/deprecating/kitchen_instance"
require "kitchen/terraform/kitchen_instance"
require "kitchen/terraform/version"

::RSpec
  .describe ::Kitchen::Terraform::KitchenInstance do
    describe ".new" do
      subject do
        described_class.new kitchen_instance: instance_double(::Object)
      end

      context "when the version is less than 4.0.0" do
        around do |example|
          ::Kitchen::Terraform::Version
            .temporarily_override(
              version: "3.4.5",
              &example
            )
        end

        specify do
          is_expected.to be_kind_of ::Kitchen::Terraform::Deprecating::KitchenInstance
        end
      end

      context "when the version is equal to 4.0.0" do
        around do |example|
          ::Kitchen::Terraform::Version
            .temporarily_override(
              version: "4.0.0",
              &example
            )
        end

        specify do
          is_expected.to be_kind_of ::Kitchen::Terraform::Breaking::KitchenInstance
        end
      end

      context "when the version is greater than 4.0.0" do
        around do |example|
          ::Kitchen::Terraform::Version
            .temporarily_override(
              version: "5.6.7",
              &example
            )
        end

        specify do
          is_expected.to be_kind_of ::Kitchen::Terraform::Breaking::KitchenInstance
        end
      end
    end
  end
