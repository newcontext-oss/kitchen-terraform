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

::RSpec.shared_examples "Kitchen::Terraform::ConfigAttribute::Groups" do
  include_context "Kitchen::Terraform::ConfigAttribute", attribute: :groups do
    describe "the basic schema" do
      context "when the config omits :groups" do
        it_behaves_like "a default value is used", default_value: []
      end

      context "when the config associates :groups with a nonarray" do
        it_behaves_like "the value is invalid", error_message: /groups.*must be an array/, value: 123
      end

      context "when the config associates :groups with an empty array" do
        it_behaves_like "the value is valid", value: []
      end

      context "when the config associates :groups with an array which includes a nonhash" do
        it_behaves_like "the value is invalid", error_message: /groups.*0.*must be a hash/, value: [123]
      end
    end

    describe "the required group attributes" do
      context "when the group is empty" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*name.*is missing.*backend.*is missing/, value: [{}]
      end

      context "when the group associates :name with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*name.*must be a string/, value: [{name: 123}]
      end

      context "when the group associates :name with an empty string" do
        it_behaves_like "the value is invalid", error_message: /groups.*0.*name.*must be filled/, value: [{name: ""}]
      end

      context "when the group associates :backend with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*backend.*must be a string/, value: [{backend: 123}]
      end

      context "when the group associates :backend with an empty string" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*backend.*must be filled/, value: [{backend: ""}]
      end

      context "when the group associates :name with a nonempty string and associates :backend with a nonempty string" do
        it_behaves_like "the value is valid", value: [{name: "example name", backend: "example backend"}]
      end
    end

    describe "the optional group attributes" do
      context "when the group associates associates :attributes with a nonhash" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*attributes.*must be a hash/, value: [{name: "abc", attributes: 123}]
      end

      context "when the group associates :attributes with a hash which has nonstring or nonsymbol keys" do
        it_behaves_like "the value is invalid",
                        error_message:
                          /groups.*0.*attributes.*must be a hash which includes only symbol keys and string values/,
                        value: [{name: "abc", attributes: {123 => "abc"}}]
      end

      context "when the group associates :attributes with a hash which has nonstring values" do
        it_behaves_like "the value is invalid",
                        error_message:
                          /groups.*0.*attributes.*must be a hash which includes only symbol keys and string values/,
                        value: [{name: "abc", attributes: {"abc" => 123}}]
      end

      context "when the group associates :attrs with a nonarray" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*attrs.*must be an array/, value: [{name: "abc", attrs: 123}]
      end

      context "when the group associates :attrs with an array which includes a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*attrs.*0.*must be a string/, value: [{name: "abc", attrs: [123]}]
      end

      context "when the group associates :backend_cache with a nonboolean" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*backend_cache.*must be boolean/, value: [{backend_cache: "abc"}]
      end

      context "when the group associates :controls with a nonarray" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*controls.*must be an array/, value: [{name: "abc", controls: 123}]
      end

      context "when the group associates :controls with an array which includes a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*controls.*0.*must be a string/,
                        value: [{name: "abc", controls: [123]}]
      end

      context "when the group associates :enable_password with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*enable_password.*must be a string/, value: [{enable_password: 123}]
      end

      context "when the group associates :enable_password with a string which is empty" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*enable_password.*must be filled/, value: [{enable_password: ""}]
      end

      context "when the group associates :hosts_output with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*hosts_output.*must be a string/, value: [{hosts_output: 123}]
      end

      context "when the group associates :key_files with a nonarray" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*key_files.*must be an array/, value: [{key_files: 123}]
      end

      context "when the group associates :key_files with an array which includes a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*key_files.*0.*must be a string/, value: [{key_files: [123]}]
      end

      context "when the group associates :password with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*password.*must be a string/, value: [{password: 123}]
      end

      context "when the group associates :password with a string which is empty" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*password.*must be filled/, value: [{password: ""}]
      end

      context "when the group associates :path with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*path.*must be a string/, value: [{path: 123}]
      end

      context "when the group associates :path with a string which is empty" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*path.*must be filled/, value: [{path: ""}]
      end

      context "when the group associates :proxy_command with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*proxy_command.*must be a string/, value: [{proxy_command: 123}]
      end

      context "when the group associates :proxy_command with a string which is empty" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*proxy_command.*must be filled/, value: [{proxy_command: ""}]
      end

      context "when the group associates :port with a noninteger" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*port.*must be an integer/, value: [{name: "abc", port: "abc"}]
      end

      context "when the group associates :reporter with a nonarray" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*reporter.*must be an array/, value: [{reporter: 123}]
      end

      context "when the group associates :reporter with an array which includes a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*reporter.*0.*must be a string/, value: [{reporter: [123]}]
      end

      context "when the group associates :reporter with an array which includes an empty string" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*reporter.*0.*must be filled/, value: [{reporter: [""]}]
      end

      context "when the group associates :self_signed with a nonboolean" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*self_signed.*must be boolean/, value: [{self_signed: "abc"}]
      end

      context "when the group associates :shell with a nonboolean" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*shell.*must be boolean/, value: [{shell: "abc"}]
      end

      context "when the group associates :user with a nonstring" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*user.*must be a string/, value: [{user: 123}]
      end

      context "when the group associates :user with a string which is empty" do
        it_behaves_like "the value is invalid",
                        error_message: /groups.*0.*user.*must be filled/, value: [{user: ""}]
      end
    end
  end
end
