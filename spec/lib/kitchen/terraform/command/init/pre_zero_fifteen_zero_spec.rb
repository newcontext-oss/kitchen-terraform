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

require "kitchen/terraform/command/init/pre_zero_fifteen_zero"

::RSpec.describe ::Kitchen::Terraform::Command::Init::PreZeroFifteenZero do
  subject do
    described_class.new config: config
  end

  let :config do
    {
      backend_configurations: {
        string: "\\\"A String\\\"",
        map: "{ key = \\\"A Value\\\" }",
        list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
      },
      color: false,
      lock: true,
      lock_timeout: 123,
      plugin_directory: "/plugins",
      root_module_directory: "/root-module",
      upgrade_during_init: true,
    }
  end

  describe "#to_s" do
    specify "should return command with flags" do
      expect(subject.to_s).to eq(
        "init " \
        "-input=false " \
        "-lock=true " \
        "-lock-timeout=123s " \
        "-no-color " \
        "-upgrade " \
        "-force-copy " \
        "-backend=true " \
        "-backend-config=\"string=\\\"A String\\\"\" " \
        "-backend-config=\"map={ key = \\\"A Value\\\" }\" " \
        "-backend-config=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
        "-get=true " \
        "-get-plugins=true " \
        "-plugin-dir=\"/plugins\" " \
        "-verify-plugins=true",
      )
    end
  end
end
