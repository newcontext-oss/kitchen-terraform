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

require "terraform/output_parser"

::RSpec.describe ::Terraform::OutputParser do
  let :described_instance do described_class.new output: output end

  describe "#parsed_output" do
    let :output do
      ::JSON.dump "output_name_1" => {"value" => "output_value_1"},
                  "output_name_2" => {"value" => "output_value_2"}
    end

    subject do described_instance.parsed_output end

    it "returns each output name" do
      is_expected.to eq "output_name_1" => "output_value_1",
                        "output_name_2" => "output_value_2"
    end
  end
end
