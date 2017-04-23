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

::RSpec.shared_context "::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes.call" do
  before do
    allow(client).to receive(:each_output_name).with(no_args).and_yield("output_name_one").and_yield "output_name_two"

    allow(client).to receive(:output).with(name: "output_name_one").and_return "output_value_one"

    allow(client).to receive(:output).with(name: "output_name_two").and_return "output_value_two"
  end
end
