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

::RSpec.describe ::Kitchen::Terraform::Transport::Connection do
  subject do
    described_class.new options
  end

  let :options do
    {}
  end

  describe "#execute" do
    let :client do
      instance_double ::String
    end

    before do
      options.store :client, client
    end

    specify "should invoke the Exec superclass implementation with the client prefixing the command" do
      expect(subject).to receive(:run_command).with "#{client} test-command"
      subject.execute "test-command"
    end
  end
end
