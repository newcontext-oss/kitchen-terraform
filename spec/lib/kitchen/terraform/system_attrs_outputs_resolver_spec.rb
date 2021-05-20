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

require "kitchen/terraform/system_attrs_outputs_resolver"

::RSpec.describe ::Kitchen::Terraform::SystemAttrsOutputsResolver do
  subject do
    described_class.new attrs: attrs
  end

  let :attrs do
    {}
  end

  describe "#resolve" do
    let :attrs_outputs do
      { inspec: :terraform }
    end

    context "when the 'value' key is absent from an output" do
      let :outputs do
        { terraform: { count: "test" } }
      end

      specify "should raise a client error" do
        expect do
          subject.resolve attrs_outputs: attrs_outputs, outputs: outputs
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when a specified output key is absent from the outputs" do
      let :outputs do
        {}
      end

      specify "should raise a client error" do
        expect do
          subject.resolve attrs_outputs: attrs_outputs, outputs: outputs
        end.to raise_error ::Kitchen::ClientError
      end
    end

    context "when the specified outputs are present and valid" do
      let :outputs do
        { terraform: { value: "test" } }
      end

      before do
        subject.resolve attrs_outputs: attrs_outputs, outputs: outputs
      end

      specify "should map attrs to outputs" do
        expect(attrs).to eq "inspec" => "test", "output_terraform" => "test", "terraform" => "test"
      end
    end
  end
end
