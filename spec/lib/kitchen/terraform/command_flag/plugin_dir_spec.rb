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

require "kitchen/terraform/command_flag/plugin_dir"

::RSpec.describe ::Kitchen::Terraform::CommandFlag::PluginDir do
  subject do
    described_class.new pathname: pathname
  end

  describe "#to_s" do
    context "when pathname is empty" do
      let :pathname do
        ""
      end

      specify "should return an empty string" do
        expect(subject.to_s).to eq ""
      end
    end

    context "when pathname is not empty" do
      let :pathname do
        "/plugins"
      end

      specify "should return -plugin-dir with the pathname" do
        expect(subject.to_s).to eq "-plugin-dir=\"/plugins\""
      end
    end
  end
end
