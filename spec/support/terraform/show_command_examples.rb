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

require 'terraform/show_command'
require_relative 'command_with_input_file_examples'
require_relative 'colored_command_examples'

::RSpec.shared_examples ::Terraform::ShowCommand do
  it_behaves_like 'colored command'

  it_behaves_like ::Terraform::CommandWithInputFile

  describe '#input_file' do
    subject { described_instance.input_file }

    it('is the target') { is_expected.to be described_instance.target }
  end

  describe '#name' do
    subject { described_instance.name }

    it('is "show"') { is_expected.to eq 'show' }
  end
end
