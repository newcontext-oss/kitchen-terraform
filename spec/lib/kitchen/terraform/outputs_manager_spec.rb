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
require "kitchen/terraform/outputs_manager"

::RSpec.describe ::Kitchen::Terraform::OutputsManager do
  subject do
    described_class.new logger: ::Kitchen::Logger.new
  end

  describe "#load" do
    let :outputs do
      {}
    end

    context "when the Kitchen instance state does not include the key 'kitchen-terraform.output-values'" do
      specify "it should raise a Kitchen::ClientError" do
        expect do
          subject.load outputs: outputs, state: {}
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the Kitchen instance state does include the key 'kitchen-terraform.output-values'" do
      before do
        subject.load(
          outputs: outputs,
          state: { kitchen_terraform_outputs: { "key" => "value" } },
        )
      end

      specify "it should load the outputs" do
        expect(outputs).to eq "key" => "value"
      end
    end
  end
end
