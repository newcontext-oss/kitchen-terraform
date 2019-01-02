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
require "kitchen/terraform/command/init"
require "kitchen/terraform/shell_out_nu"

::RSpec.describe ::Kitchen::Terraform::Command::Init do
  describe ".run" do
    let :backend_config do
      {list: backend_config_list, map: backend_config_map, string: backend_config_string}
    end

    let :backend_config_list do
      "[ \\\"Element One\\\", \\\"Element Two\\\" ]"
    end

    let :backend_config_map do
      "{ key = \\\"A Value\\\" }"
    end

    let :backend_config_string do
      "\\\"A String\\\""
    end

    let :directory do
      "/directory"
    end

    let :output do
      "output"
    end

    let :timeout do
      1234
    end

    let :init do
      described_class.new(
        backend_config: backend_config,
        color: false,
        directory: directory,
        lock: lock,
        lock_timeout: lock_timeout,
        plugin_dir: plugin_dir,
        timeout: timeout,
        upgrade: upgrade,
      )
    end

    let :lock do
      true
    end

    let :lock_timeout do
      "10s"
    end

    let :plugin_dir do
      "/Arbitrary Directory/Plugin Directory"
    end

    let :upgrade do
      true
    end

    before do
      allow(::Kitchen::Terraform::ShellOutNu).to receive(:run_command).with(
        "terraform init " \
        "-input=false " \
        "-force-copy " \
        "-backend=true " \
        "-get=true " \
        "-get-plugins=true " \
        "-verify-plugins=true " \
        "-lock=#{lock} " \
        "-lock-timeout=#{lock_timeout} " \
        "-no-color " \
        "-upgrade " \
        "-backend-config=\"list=#{backend_config_list}\" " \
        "-backend-config=\"map=#{backend_config_map}\" " \
        "-backend-config=\"string=#{backend_config_string}\" " \
        "-plugin-dir=\"#{plugin_dir}\"",
        cwd: directory,
        environment: kind_of(::Hash),
        timeout: timeout,
      ).and_return output
    end

    specify "should yield the result of running `terraform init`" do
      expect do |block|
        described_class.run(
          backend_config: backend_config,
          color: false,
          directory: directory,
          lock: lock,
          lock_timeout: lock_timeout,
          plugin_dir: plugin_dir,
          timeout: timeout,
          upgrade: upgrade,
          &block
        )
      end.to yield_with_args init: init
    end
  end
end
