# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
#
# Licensed under the Apache License, Version 2.0 (the &quot;License&quot;);
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an &quot;AS IS&quot; BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'support/terraform/client_context'
require 'terraform/group_hostnames'

::RSpec.describe ::Terraform::GroupHostnames do
  let(:config_value) { 'name' }

  let(:described_instance) { described_class.new config_value }

  describe '#resolve' do
    include_context 'client'

    subject { ->(block) { described_instance.resolve client: client, &block } }

    context 'when a hostnames output name is specified' do
      before do
        allow(client).to receive(:iterate_output)
          .with(name: 'name').and_yield('value_1').and_yield 'value_2'
      end

      it 'yields the hostnames output values' do
        is_expected.to yield_successive_args 'value_1', 'value_2'
      end
    end

    context 'when a hostnames output name is not specified' do
      let(:config_value) { '' }

      it('yields "localhost"') { is_expected.to yield_with_args 'localhost' }
    end
  end

  describe '#to_s' do
    subject { described_instance.to_s }

    it('returns the config value') { is_expected.to eq 'name' }
  end
end
