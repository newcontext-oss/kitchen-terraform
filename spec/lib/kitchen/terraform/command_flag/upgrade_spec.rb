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

require "kitchen/terraform/command_flag/upgrade"

::RSpec.describe ::Kitchen::Terraform::CommandFlag::Upgrade do
  describe "#to_s" do
    subject do
      described_class.new command: command, upgrade: upgrade
    end

    let :command do
      ::Object.new
    end

    context "when upgrade is `true`" do
      let :upgrade do
        true
      end

      specify "should return the command string appended with '-upgrade'" do
        expect(subject.to_s).to eq "#{command} -upgrade"
      end
    end

    context "when upgrade is `false`" do
      let :upgrade do
        false
      end

      specify "should return the command string" do
        expect(subject.to_s).to eq command.to_s
      end
    end
  end
end
