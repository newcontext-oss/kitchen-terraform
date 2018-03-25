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
require "kitchen/terraform/version"

::RSpec
  .describe ::Kitchen::Terraform::Breaking::KitchenInstance do
    describe ".===(version)" do
      context "when the version is less than 4.0.0" do
        it do
          expect(described_class.===(::Kitchen::Terraform::Version.new(version: "3.4.5"))).to be false
        end
      end

      context "when the version is equal to 4.0.0" do
        it do
          expect(described_class.===(::Kitchen::Terraform::Version.new(version: "4.0.0"))).to be true
        end
      end

      context "when the version is greater than 4.0.0" do
        it do
          expect(described_class.===(::Kitchen::Terraform::Version.new(version: "5.6.7"))).to be true
        end
      end
    end
  end
