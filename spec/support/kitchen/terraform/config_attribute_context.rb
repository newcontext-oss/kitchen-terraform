# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "support/kitchen/instance_context"

::RSpec
  .shared_context "Kitchen::Terraform::ConfigAttribute" do |attribute:|
    include_context ::Kitchen::Instance

    shared_context "value validation" do |value:|
      let :plugin do
        described_class
          .new(
            kitchen_root: "kitchen_root",
            attribute => value
          )
      end

      subject do
        lambda do
          plugin.finalize_config! instance
        end
      end
    end

    shared_examples "the value is invalid" do |error_message:, value:|
      include_context(
        "value validation",
        value: value
      ) do
        it "raises a user error" do
          is_expected
            .to(
              raise_error(
                ::Kitchen::UserError,
                error_message
              )
            )
        end
      end
    end

    shared_examples "the value is valid" do |value:|
      include_context(
        "value validation",
        value: value
      ) do
        it "does not raise an error" do
          is_expected.to_not raise_error
        end
      end
    end

    shared_examples "a default value is used" do |default_value:|
      let :plugin do
        described_class.new kitchen_root: "kitchen_root"
      end

      before do
        plugin.finalize_config! instance
      end

      subject do
        plugin[attribute]
      end

      it "associates :#{attribute} with #{default_value}" do
        is_expected.to match default_value
      end
    end
  end
