# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "kitchen/terraform/inspec_options_factory"

::RSpec.describe ::Kitchen::Terraform::InSpecOptionsFactory do
  describe ".inputs_key" do
    context "when the InSpec version is less than 4.3.2" do
      before do
        stub_const "::Inspec::VERSION", "4.3.1"
      end

      specify "should return :attributes" do
        expect(described_class.inputs_key).to eq :attributes
      end
    end

    context "when the InSpec version is greater than or equal to 4.3.2" do
      before do
        stub_const "::Inspec::VERSION", "4.3.2"
      end

      specify "should return :inputs" do
        expect(described_class.inputs_key).to eq :inputs
      end
    end
  end

  describe "#build" do
    let :attributes do
      { key: "value" }
    end

    let :system_configuration_attributes do
      {
        attrs: "./inputs",
        backend_cache: "./backend-cache",
        backend: "ssh",
        bastion_host: "bastion-host",
        bastion_port: 1234,
        bastion_user: "bastion-user",
        color: true,
        controls: ["control"],
        enable_password: "enable-password",
        key_files: ["./key"],
        password: "password",
        path: "./path",
        port: 1234,
        proxy_command: "./proxy",
        reporter: "reporter",
        self_signed: true,
        shell_command: "./shell",
        shell_options: "--shell-option",
        shell: true,
        show_progress: true,
        ssl: true,
        sudo_command: "./sudo",
        sudo_options: "--sudo-option",
        sudo_password: "sudo-password",
        sudo: true,
        user: "user",
        vendor_cache: "./vendor-cache",
      }
    end

    specify "should filter and map system configuration attributes to InSpec options along with input attributes" do
      expect(
        subject.build(attributes: attributes, system_configuration_attributes: system_configuration_attributes)
      ).to eq(
        described_class.inputs_key => { key: "value" },
        input_file: "./inputs",
        backend_cache: "./backend-cache",
        backend: "ssh",
        bastion_host: "bastion-host",
        bastion_port: 1234,
        bastion_user: "bastion-user",
        "color" => true,
        controls: ["control"],
        "distinct_exit" => false,
        enable_password: "enable-password",
        key_files: ["./key"],
        password: "password",
        path: "./path",
        port: 1234,
        proxy_command: "./proxy",
        "reporter" => "reporter",
        self_signed: true,
        shell_command: "./shell",
        shell_options: "--shell-option",
        shell: true,
        show_progress: true,
        ssl: true,
        sudo_command: "./sudo",
        sudo_options: "--sudo-option",
        sudo_password: "sudo-password",
        sudo: true,
        user: "user",
        vendor_cache: "./vendor-cache",
      )
    end
  end
end
