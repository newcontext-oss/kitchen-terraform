# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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
require "kitchen/terraform/transport/connection"
require "kitchen/transport/exec"
require "mixlib/shellout"

::RSpec.describe ::Kitchen::Terraform::Transport::Connection do
  subject do
    described_class.new options
  end

  let :options do
    {}
  end

  describe "#run_command" do
    let :client do
      instance_double ::String
    end

    let :shell_out do
      instance_double ::Mixlib::ShellOut
    end

    before do
      options.store :client, client
    end

    specify "should invoke the ShellOut superclass implementation with the client and environment configured" do
      allow(shell_out).to receive :run_command
      allow(shell_out).to receive :execution_time
      allow(shell_out).to receive :error!
      allow(shell_out).to receive(:stdout).and_return :superclass
      allow(::Mixlib::ShellOut).to receive(:new).with(
        "#{client} test-command",
        including({environment: { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true" }})
      ).and_return shell_out
      expect(subject.run_command("test-command")).to eq :superclass
    end
  end
end
