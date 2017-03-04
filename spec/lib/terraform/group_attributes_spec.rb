# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require 'terraform/client'
require 'terraform/group_attributes'

::RSpec.describe ::Terraform::GroupAttributes do
  let(:described_instance) { described_class.coerce config_value }

  describe '#resolve' do
    let(:client) { instance_double ::Terraform::Client }

    let :config_value do
      {
        'output_name_1' => 'not_output_name_1',
        'attribute_name' => 'output_name_2'
      }
    end

    before do
      allow(client).to receive(:each_output_name)
        .with(no_args).and_yield('output_name_1').and_yield 'output_name_2'

      allow(client).to receive(:output)
        .with(name: 'not_output_name_1').and_return 'output_value_1'

      allow(client).to receive(:output)
        .with(name: 'output_name_2').and_return 'output_value_2'

      described_instance.resolve client: client
    end

    subject { described_instance }

    it 'resolves attributes with priority for user defined attributes' do
      is_expected.to include 'output_name_1' => 'output_value_1',
                             'attribute_name' => 'output_value_2',
                             'output_name_2' => 'output_value_2'
    end
  end
end
