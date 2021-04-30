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

require "kitchen/terraform/command/validate/pre_zero_fifteen_zero"

::RSpec.describe ::Kitchen::Terraform::Command::Validate::PreZeroFifteenZero do
  subject do
    described_class.new config: config
  end

  let :config do
    {
      color: false,
      variable_files: ["/one.tfvars", "/two.tfvars"],
      variables: {
        string: "\\\"A String\\\"",
        map: "{ key = \\\"A Value\\\" }",
        list: "[ \\\"Element One\\\", \\\"Element Two\\\" ]",
      },
    }
  end

  describe "#to_s" do
    specify "should return the command with flags" do
      # -var and -var-file are included for compatibility with Terraform 0.11
      expect(subject.to_s).to eq(
        "validate " \
        "-no-color " \
        "-var=\"string=\\\"A String\\\"\" " \
        "-var=\"map={ key = \\\"A Value\\\" }\" " \
        "-var=\"list=[ \\\"Element One\\\", \\\"Element Two\\\" ]\" " \
        "-var-file=\"/one.tfvars\" " \
        "-var-file=\"/two.tfvars\""
      )
    end
  end
end
