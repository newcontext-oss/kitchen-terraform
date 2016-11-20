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

require 'terraform/destructive_plan_command'
require_relative 'command_with_input_file_examples'
require_relative 'plan_command_examples'

::RSpec.shared_examples ::Terraform::DestructivePlanCommand do
  it_behaves_like ::Terraform::CommandWithInputFile

  it_behaves_like ::Terraform::PlanCommand

  describe '#input_file' do
    subject { described_instance.input_file }

    it 'is the state option' do
      is_expected.to be described_instance.options.state
    end
  end

  describe '#options' do
    subject { described_instance.options.to_s }

    it('includes -destroy=true') { is_expected.to include '-destroy=true' }
  end
end
