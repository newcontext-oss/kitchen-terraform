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
require "tempfile"

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
          value:
            [
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
          value:
            [
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
          error_message:
            /groups.*0.*attributes.*must be a hash which includes only symbol keys and string values/,
          value:
            [
              {
                name: "abc",
                attributes: {123 => "abc"}
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
          error_message:
            /groups.*0.*attributes.*must be a hash which includes only symbol keys and string values/,
          value:
            [
              {
                name: "abc",
                attributes: {"abc" => 123}
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
          value:
            [
              {
                name: "abc",
                attributes: {key: "value"}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :hostnames with a nonstring"
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
          "the value is invalid",
          error_message: /groups.*0.*hostnames.*must be filled/,
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
          "nonempty string and associates :inspec_options with a nonhash"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*must be a hash/,
          value:
            [
              {
                name: "abc",
                inspec_options: 123
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with an empty hash"
      ) do
        it_behaves_like(
          "the value is valid",
          value:
            [
              {
                name: "abc",
                inspec_options: {}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :attrs with a nonarray"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*attrs.*must be an array/,
          value:
            [
              {
                name: "abc",
                inspec_options: {attrs: 123}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :attrs with an empty array"
      ) do
        it_behaves_like(
          "the value is valid",
          value:
            [
              {
                name: "abc",
                inspec_options: {attrs: []}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :attrs with an array which " \
          "includes a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*attrs.*0.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {attrs: [123]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :attrs with an array which " \
          "includes an empty string "
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*attrs.*0.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {attrs: [""]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :attrs with an array which " \
          "includes a string which contains a path to a nonexistent file"
      ) do
        file = ::Tempfile.new

        before do
          file.unlink
        end

        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*attrs.*0.*must be a path to an existent file/,
          value: [
            {
              name: "abc",
              inspec_options: {attrs: [file.path]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :attrs with an array which " \
          "includes a string which contains a path to a existent file"
      ) do
        file = ::Tempfile.new

        after do
          file.unlink
        end

        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {attrs: [file.path]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :backend with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*backend.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {backend: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :backend with an empty string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*backend.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {backend: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :backend with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {backend: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :backend_cache with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*backend_cache.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {backend_cache: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :backend_cache with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {backend_cache: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :controls with a nonarray"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*controls.*must be an array/,
          value:
            [
              {
                name: "abc",
                inspec_options: {controls: 123}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :controls with an empty array"
      ) do
        it_behaves_like(
          "the value is valid",
          value:
            [
              {
                name: "abc",
                inspec_options: {controls: []}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :controls with an array which " \
          "includes a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*controls.*0.*must be a string/,
          value:
            [
              {
                name: "abc",
                inspec_options: {controls: [123]}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :controls with an array which " \
          "includes a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value:
            [
              {
                name: "abc",
                inspec_options: {controls: ["abc"]}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :create_lockfile with a " \
          "nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*create_lockfile.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {create_lockfile: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :create_lockfile with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {create_lockfile: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :key_files with a nonarray"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*key_files.*must be an array/,
          value: [
            {
              name: "abc",
              inspec_options: {key_files: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :key_files with an empty array"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {key_files: []}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :key_files with an array " \
          "which includes a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*key_files.*0.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {key_files: [123]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :key_files with an array " \
          "which includes a string which contains a path to a nonexistent file"
      ) do
        file = ::Tempfile.new

        before do
          file.unlink
        end

        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*key_files.*0.*must be a path to an existent file/,
          value: [
            {
              name: "abc",
              inspec_options: {key_files: [file.path]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :key_files with an array " \
          "which includes a string which contains a path to a existent file"
      ) do
        file = ::Tempfile.new

        after do
          file.unlink
        end

        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {key_files: [file.path]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :password with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*password.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {password: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :password with an empty string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*password.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {password: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :password with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {password: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :path with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*path.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {path: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :path with an empty string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*path.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {path: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :path with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {path: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :port with a noninteger"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*port.*must be an integer/,
          value: [
            {
              name: "abc",
              inspec_options: {port: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :port with an integer"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {port: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :reporter with a nonarray"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*reporter.*must be an array/,
          value:
            [
              {
                name: "abc",
                inspec_options: {reporter: 123}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :reporter with an empty array"
      ) do
        it_behaves_like(
          "the value is valid",
          value:
            [
              {
                name: "abc",
                inspec_options: {reporter: []}
              }
            ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :reporter with an array which " \
          "includes a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*reporter.*0.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {reporter: [123]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :reporter with an array which " \
          "includes an empty string "
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*reporter.*0.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {reporter: [""]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :reporter with an array which " \
          "includes a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {reporter: ["abc"]}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :self_signed with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*self_signed.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {self_signed: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :self_signed with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {self_signed: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*shell.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {shell: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {shell: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell_command with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*shell_command.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {shell_command: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell_command with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*shell_command.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {shell_command: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell_command with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {shell_command: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell_options with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*shell_options.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {shell_options: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell_options with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*shell_options.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {shell_options: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :shell_options with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {shell_options: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :show_progress with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*show_progress.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {show_progress: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :show_progress with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {show_progress: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :ssl with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*ssl.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {ssl: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :ssl with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {ssl: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo with a nonboolean"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo.*must be boolean/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo with a boolean"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {sudo: true}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_command with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo_command.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo_command: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_command with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo_command.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo_command: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_command with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {sudo_command: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_options with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo_options.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo_options: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_options with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo_options.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo_options: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_options with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {sudo_options: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_password with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo_password.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo_password: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_password with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*sudo_password.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {sudo_password: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :sudo_password with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {sudo_password: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :user with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*user.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {user: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :user with an empty string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*user.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {user: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :user with a nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {user: "abc"}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :vendor_cache with a nonstring"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*vendor_cache.*must be a string/,
          value: [
            {
              name: "abc",
              inspec_options: {vendor_cache: 123}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :vendor_cache with an empty " \
          "string"
      ) do
        it_behaves_like(
          "the value is invalid",
          error_message: /groups.*0.*inspec_options.*vendor_cache.*must be filled/,
          value: [
            {
              name: "abc",
              inspec_options: {vendor_cache: ""}
            }
          ]
        )
      end

      context(
        "when the config associates :groups with an array which includes a hash which associates :name with a " \
          "nonempty string and associates :inspec_options with a hash which associates :vendor_cache with a " \
          "nonempty string"
      ) do
        it_behaves_like(
          "the value is valid",
          value: [
            {
              name: "abc",
              inspec_options: {vendor_cache: "abc"}
            }
          ]
        )
      end
    end
  end
