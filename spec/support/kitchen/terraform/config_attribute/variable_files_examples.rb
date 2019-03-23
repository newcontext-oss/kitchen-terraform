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

require "support/kitchen/terraform/config_attribute_context"

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::VariableFiles" do
  include_context(
    "Kitchen::Terraform::ConfigAttribute",
    attribute: :variable_files,
  ) do
    context "when the config omits :variable_files" do
      it_behaves_like(
        "a default value is used",
        default_value: [],
      )
    end

    context "when the config associates :variable_files with a nonarray" do
      it_behaves_like(
        "the value is invalid",
        error_message: /variable_files.*must be an array/,
        value: "abc",
      )
    end

    context "when the config associates :variable_files with an empty array" do
      it_behaves_like(
        "the value is valid",
        value: [],
      )
    end

    context "when the config associates :variable_files with an array which includes a nonstring" do
      it_behaves_like(
        "the value is invalid",
        error_message: /variable_files.*0.*must be a string/,
        value: [123],
      )
    end

    context "when the config associates :variable_files with an array which includes an empty string" do
      it_behaves_like(
        "the value is invalid",
        error_message: /variable_files.*0.*must be filled/,
        value: [""],
      )
    end

    context "when the config associates :variable_files with an array which includes a nonempty string" do
      it_behaves_like(
        "the value is valid",
        value: ["abc"],
      )
    end
  end
end
