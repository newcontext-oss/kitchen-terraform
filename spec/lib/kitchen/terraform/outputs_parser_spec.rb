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
require "kitchen/terraform/outputs_parser"

::RSpec.describe ::Kitchen::Terraform::OutputsParser do
  subject do
    described_class.new
  end

  describe "#parse" do
    context "when the outputs are not valid JSON" do
      specify "should raise a transient failure error" do
        expect do
          subject.parse json_outputs: "invalid"
        end.to raise_error ::Kitchen::TransientFailure
      end
    end

    context "when the outputs are valid JSON" do
      specify "should yield the parsed outputs" do
        expect do |block|
          subject.parse json_outputs: "{\"key\": \"value\"}", &block
        end.to yield_with_args parsed_outputs: { "key" => "value" }
      end
    end
  end
end
