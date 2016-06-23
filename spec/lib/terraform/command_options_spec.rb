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

require 'terraform/command_options'

RSpec.describe Terraform::CommandOptions do
  describe '#to_s' do
    let :described_instance do
      described_class.new single_argument: 'argument',
                          multiple_arguments: %w(argument argument)
    end

    subject { described_instance.to_s }

    it 'transform the options in to flags' do
      is_expected.to eq '-single-argument=argument ' \
                          '-multiple-arguments=argument ' \
                          '-multiple-arguments=argument'
    end
  end
end
