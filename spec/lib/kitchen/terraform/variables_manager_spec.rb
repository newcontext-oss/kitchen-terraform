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

require "kitchen"
require "kitchen/terraform/variables_manager"

::RSpec.describe ::Kitchen::Terraform::VariablesManager do
  subject do
    described_class.new logger: ::Kitchen::Logger.new
  end

  describe "#load" do
    let :variables do
      {}
    end

    context "when the Kitchen instance state does not include the key 'kitchen-terraform.input-variables'" do
      specify "it should raise a Kitchen::ClientError" do
        expect do
          subject.load variables: variables, state: {}
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the Kitchen instance state does include the key 'kitchen-terraform.input-variables'" do
      before do
        subject.load(
          variables: variables,
          state: { kitchen_terraform_variables: { "key" => "value" } },
        )
      end

      specify "it should load the variables" do
        expect(variables).to eq "key" => "value"
      end
    end
  end
end
