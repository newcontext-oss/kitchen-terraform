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

require 'terraform/output_command'

RSpec.describe Terraform::OutputCommand do
  let(:described_instance) { described_class.new logger: logger, state: state }

  let(:logger) { instance_double Object }

  let(:state) { instance_double Object }

  describe '#name' do
    subject { described_instance.name }

    it('returns "output"') { is_expected.to eq 'output' }
  end

  describe '#options' do
    subject { described_instance.options }

    it 'returns "-state=<state_pathname>"' do
      is_expected.to eq "-state=#{state}"
    end
  end
end
