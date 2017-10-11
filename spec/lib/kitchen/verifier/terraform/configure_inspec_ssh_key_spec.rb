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

require "kitchen/verifier/terraform/configure_inspec_runner_ssh_key"

::RSpec
  .describe ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerSSHKey do
    let :options do
      {"key_files" => options_key_files}
    end

    let :options_key_files do
      [instance_double(::Object)]
    end

    before do
      described_class
        .call(
          group: group,
          options: options
        )
    end

    subject do
      options.fetch "key_files"
    end

    context "when the group associates :ssh_key with an object" do
      let :group do
        {ssh_key: group_ssh_key}
      end

      let :group_ssh_key do
        instance_double ::Object
      end

      it "associates the options' 'key_files' with an array containing the group's :ssh_key" do
        is_expected.to eq [group_ssh_key]
      end
    end

    context "when the group omits :ssh_key" do
      let :group do
        {}
      end

      it "does not change the options' 'key_files'" do
        is_expected.to eq options_key_files
      end
    end
  end
