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

::RSpec
  .shared_examples "Kitchen::Terraform::ConfigAttribute::Groups" do
    include_context(
      "Kitchen::Terraform::ConfigAttribute",
      attribute: :groups
    ) do
      context "when the config omits :groups" do
        it_behaves_like(
          "a default value is used",
          default_value: []
        )
      end

      context "when the config associates :groups with a nonarray" do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*must be an array/,
          value: 123
        )
      end

      context "when the config associates :groups with an empty array" do
        it_behaves_like(
          "the value is valid",
          value: []
        )
      end

      context "when the config associates :groups with an array which includes a nonhash" do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*must be a hash/,
          value: [123]
        )
      end

      context "when the config associates :groups with an array which includes an empty hash" do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*name.*is missing/,
          value: [{}]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*name.*must be a string/,
          value: [{name: 123}]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*name.*must be filled/,
          value: [{name: ""}]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [{name: "abc"}]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :attributes with a nonhash"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*attributes.*must be a hash/,
          value: [
            {
              name: "abc",
              attributes: 123
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :attributes with an empty hash"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              attributes: {}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :attributes with a hash which has nonstring or nonsymbol keys"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*attributes.*must be a hash which includes only symbol keys and string values/,
          value: [
            {
              name: "abc",
              attributes: {
                123 => "abc"
              }
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :attributes with a hash which has nonstring values"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*attributes.*must be a hash which includes only symbol keys and string values/,
          value: [
            {
              name: "abc",
              attributes: {
                "abc" => 123
              }
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :attributes with a hash which has symobl keys and string values"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              attributes: {key: "value"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :controls with a nonarray"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*controls.*must be an array/,
          value: [
            {
              name: "abc",
              controls: 123
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :controls with an empty array"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              controls: []
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :controls with an array which includes a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*controls.*0.*must be a string/,
          value: [
            {
              name: "abc",
              controls: [123]
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :controls with an array which includes a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              controls: ["abc"]
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :fail_fast with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*fail_fast.*must be boolean/,
          value: [
            {
              name: "abc",
              fail_fast: "abc"
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :fail_fast with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              fail_fast: true
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and :hostnames with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*hostnames.*must be a string/,
          value: [
            {
              name: "abc",
              hostnames: 123
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :hostnames with an empty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              hostnames: ""
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :hostnames with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              hostnames: "abc"
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and :port with a noninteger"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*port.*must be an integer/,
          value: [
            {
              name: "abc",
              port: "abc"
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :port with an integer"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              port: 123
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and :ssh_key with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*ssh_key.*must be a string/,
          value: [
            {
              name: "abc",
              ssh_key: 123
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :ssh_key with an empty string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*ssh_key.*must be filled/,
          value: [
            {
              name: "abc",
              ssh_key: ""
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :ssh_key with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              ssh_key: "abc"
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and :username with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*username.*must be a string/,
          value: [
            {
              name: "abc",
              username: 123
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :username with an empty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              username: ""
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :username with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              username: "abc"
            }
          ]
        )
      end
    end
  end
