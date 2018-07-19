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

require "kitchen/terraform/config_schemas/group"

::RSpec.describe "Kitchen::Terraform::ConfigSchemas::Group" do
  subject do
    ::Kitchen::Terraform::ConfigSchemas::Group
  end

  describe ".call" do
    specify "the input must include :name" do
      expect(subject.call({}).errors).to include name: ["is missing"]
    end

    specify "the input must associate :name with a string" do
      expect(subject.call(name: 123).errors).to include name: ["must be a string"]
    end

    specify "the input must associate :name with a nonempty string" do
      expect(subject.call(name: "").errors).to include name: ["must be filled"]
    end

    specify "the input must include :backend" do
      expect(subject.call({}).errors).to include backend: ["is missing"]
    end

    specify "the input must associate :backend with a string" do
      expect(subject.call(backend: 123).errors).to include backend: ["must be a string"]
    end

    specify "the input must associate :backend with a nonempty string" do
      expect(subject.call(backend: "").errors).to include backend: ["must be filled"]
    end

    specify "the input may include :attributes" do
      expect(subject.call({}).errors).not_to include attributes: ["is missing"]
    end

    specify "the input must associate :attributes with a hash" do
      expect(subject.call(attributes: 123).errors).to include attributes: ["must be a hash"]
    end

    specify "the input may include :attrs" do
      expect(subject.call({}).errors).not_to include attrs: ["is missing"]
    end

    specify "the input must associate :attrs with an array" do
      expect(subject.call(attrs: 123).errors).to include attrs: ["must be an array"]
    end

    specify "the input must associate :attrs with an array which includes strings" do
      expect(subject.call(attrs: [123]).errors).to include attrs: {0 => ["must be a string"]}
    end

    specify "the input must associate :attrs with an array which includes nonempty strings" do
      expect(subject.call(attrs: [""]).errors).to include attrs: {0 => ["must be filled"]}
    end

    specify "the input may include :backend_cache" do
      expect(subject.call({}).errors).not_to include backend_cache: ["is missing"]
    end

    specify "the input must associate :backend_cache with a boolean" do
      expect(subject.call(backend_cache: 123).errors).to include backend_cache: ["must be boolean"]
    end

    specify "the input may include :bastion_host" do
      expect(subject.call({}).errors).not_to include bastion_host: ["is missing"]
    end

    specify "the input must associate :bastion_host with a string" do
      expect(subject.call({bastion_host: 123}).errors).to include bastion_host: ["must be a string"]
    end

    specify "the input must associate :bastion_host with a nonempty string" do
      expect(subject.call(bastion_host: "").errors).to include bastion_host: ["must be filled"]
    end

    specify "the input may include :bastion_port" do
      expect(subject.call({}).errors).not_to include bastion_port: ["is missing"]
    end

    specify "the input must associate :bastion_port with an integer" do
      expect(subject.call({bastion_port: "abc"}).errors).to include bastion_port: ["must be an integer"]
    end

    specify "the input may include :bastion_user" do
      expect(subject.call({}).errors).not_to include bastion_user: ["is missing"]
    end

    specify "the input must associate :bastion_user with a string" do
      expect(subject.call({bastion_user: 123}).errors).to include bastion_user: ["must be a string"]
    end

    specify "the input must associate :bastion_user with a nonempty string" do
      expect(subject.call(bastion_user: "").errors).to include bastion_user: ["must be filled"]
    end

    specify "the input may include :controls" do
      expect(subject.call({}).errors).not_to include controls: ["is missing"]
    end

    specify "the input must associate :controls with an array" do
      expect(subject.call(controls: 123).errors).to include controls: ["must be an array"]
    end

    specify "the input must associate :controls with an array which includes strings" do
      expect(subject.call(controls: [123]).errors).to include controls: {0 => ["must be a string"]}
    end

    specify "the input must associate :controls with an array which includes nonempty strings" do
      expect(subject.call(controls: [""]).errors).to include controls: {0 => ["must be filled"]}
    end

    specify "the input may include :enable_password" do
      expect(subject.call({}).errors).not_to include enable_password: ["is missing"]
    end

    specify "the input must associate :enable_password with a string" do
      expect(subject.call(enable_password: 123).errors).to include enable_password: ["must be a string"]
    end

    specify "the input must associate :enable_password with a nonempty string" do
      expect(subject.call(enable_password: "").errors).to include enable_password: ["must be filled"]
    end

    specify "the input may include :hosts_output" do
      expect(subject.call({}).errors).not_to include hosts_output: ["is missing"]
    end

    specify "the input must associate :hosts_output with a string" do
      expect(subject.call(hosts_output: 123).errors).to include hosts_output: ["must be a string"]
    end

    specify "the input must associate :hosts_output with a nonempty string" do
      expect(subject.call(hosts_output: "").errors).to include hosts_output: ["must be filled"]
    end

    specify "the input may include :key_files" do
      expect(subject.call({}).errors).not_to include key_files: ["is missing"]
    end

    specify "the input must associate :key_files with an array" do
      expect(subject.call(key_files: 123).errors).to include key_files: ["must be an array"]
    end

    specify "the input must associate :key_files with an array which includes strings" do
      expect(subject.call(key_files: [123]).errors).to include key_files: {0 => ["must be a string"]}
    end

    specify "the input must associate :key_files with an array which includes nonempty strings" do
      expect(subject.call(key_files: [""]).errors).to include key_files: {0 => ["must be filled"]}
    end

    specify "the input may include :password" do
      expect(subject.call({}).errors).not_to include password: ["is missing"]
    end

    specify "the input must associate :password with a string" do
      expect(subject.call(password: 123).errors).to include password: ["must be a string"]
    end

    specify "the input must associate :password with a nonempty string" do
      expect(subject.call(password: "").errors).to include password: ["must be filled"]
    end

    specify "the input may include :path" do
      expect(subject.call({}).errors).not_to include path: ["is missing"]
    end

    specify "the input must associate :path with a string" do
      expect(subject.call(path: 123).errors).to include path: ["must be a string"]
    end

    specify "the input must associate :path with a nonempty string" do
      expect(subject.call(path: "").errors).to include path: ["must be filled"]
    end

    specify "the input may include :port" do
      expect(subject.call({}).errors).not_to include port: ["is missing"]
    end

    specify "the input must associate :port with an integer" do
      expect(subject.call(port: "abc").errors).to include port: ["must be an integer"]
    end

    specify "the input may include :proxy_command" do
      expect(subject.call({}).errors).not_to include proxy_command: ["is missing"]
    end

    specify "the input must associate :proxy_command with a string" do
      expect(subject.call(proxy_command: 123).errors).to include proxy_command: ["must be a string"]
    end

    specify "the input must associate :proxy_command with a nonempty string" do
      expect(subject.call(proxy_command: "").errors).to include proxy_command: ["must be filled"]
    end

    specify "the input may include :reporter" do
      expect(subject.call({}).errors).not_to include reporter: ["is missing"]
    end

    specify "the input must associate :reporter with an array" do
      expect(subject.call(reporter: 123).errors).to include reporter: ["must be an array"]
    end

    specify "the input must associate :reporter with an array which includes strings" do
      expect(subject.call(reporter: [123]).errors).to include reporter: {0 => ["must be a string"]}
    end

    specify "the input must associate :reporter with an array which includes nonempty strings" do
      expect(subject.call(reporter: [""]).errors).to include reporter: {0 => ["must be filled"]}
    end

    specify "the input may include :self_signed" do
      expect(subject.call({}).errors).not_to include self_signed: ["is missing"]
    end

    specify "the input must associate :self_signed with a boolean" do
      expect(subject.call(self_signed: 123).errors).to include self_signed: ["must be boolean"]
    end

    specify "the input may include :shell" do
      expect(subject.call({}).errors).not_to include shell: ["is missing"]
    end

    specify "the input must associate :shell with a boolean" do
      expect(subject.call(shell: 123).errors).to include shell: ["must be boolean"]
    end

    specify "the input may include :shell_command" do
      expect(subject.call({}).errors).not_to include shell_command: ["is missing"]
    end

    specify "the input must associate :shell_command with a string" do
      expect(subject.call(shell_command: 123).errors).to include shell_command: ["must be a string"]
    end

    specify "the input must associate :shell_command with a nonempty string" do
      expect(subject.call(shell_command: "").errors).to include shell_command: ["must be filled"]
    end

    specify "the input may include :shell_options" do
      expect(subject.call({}).errors).not_to include shell_options: ["is missing"]
    end

    specify "the input must associate :shell_options with a string" do
      expect(subject.call(shell_options: 123).errors).to include shell_options: ["must be a string"]
    end

    specify "the input must associate :shell_options with a nonempty string" do
      expect(subject.call(shell_options: "").errors).to include shell_options: ["must be filled"]
    end

    specify "the input may include :show_progress" do
      expect(subject.call({}).errors).not_to include show_progress: ["is missing"]
    end

    specify "the input must associate :show_progress with a boolean" do
      expect(subject.call(show_progress: 123).errors).to include show_progress: ["must be boolean"]
    end

    specify "the input may include :user" do
      expect(subject.call({}).errors).not_to include user: ["is missing"]
    end

    specify "the input must associate :user with a string" do
      expect(subject.call(user: 123).errors).to include user: ["must be a string"]
    end

    specify "the input must associate :user with a nonempty string" do
      expect(subject.call(user: "").errors).to include user: ["must be filled"]
    end
  end
end
