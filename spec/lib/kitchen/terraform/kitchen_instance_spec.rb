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
require "kitchen/terraform/breaking/kitchen_instance"
require "kitchen/terraform/deprecating/kitchen_instance"
require "kitchen/terraform/kitchen_instance"
require "kitchen/terraform/version"

::RSpec
  .describe ::Kitchen::Terraform::KitchenInstance do
    describe ".new" do
      subject do
        described_class
      end

      let :kitchen_instance do
        instance_double ::Kitchen::Instance
      end

      around do |example|
        ::Kitchen::Terraform::Version
          .temporarily_override(
            version: version,
            &example
          )
      end

      shared_examples "it should return a breaking Kitchen Instance" do
        specify do
          expect(subject.new(kitchen_instance: kitchen_instance))
            .to be_kind_of ::Kitchen::Terraform::Breaking::KitchenInstance
        end
      end

      context "when the version is less than 4.0.0" do
        let :version do
          "3.4.5"
        end

        specify "should return a deprecated Kitchen Instance" do
          expect(subject.new(kitchen_instance: kitchen_instance))
            .to be_kind_of ::Kitchen::Terraform::Deprecating::KitchenInstance
        end
      end

      context "when the version is equal to 4.0.0" do
        let :version do
          "4.0.0"
        end

        it_behaves_like "it should return a breaking Kitchen Instance"
      end

      context "when the version is greater than 4.0.0" do
        let :version do
          "5.6.7"
        end

        it_behaves_like "it should return a breaking Kitchen Instance"
      end
    end
  end
