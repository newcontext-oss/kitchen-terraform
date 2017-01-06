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

require 'support/terraform/client_context'
require 'terraform/group'

::RSpec.describe ::Terraform::Group do
  let(:config_value) { { name: 'name' } }

  let(:described_instance) { described_class.new config_value }

  describe '#description' do
    before { config_value.merge! hostname: 'hostname' }

    subject { described_instance.description }

    it 'describes the group' do
      is_expected.to eq "host 'hostname' of group 'name'"
    end
  end

  describe '#resolve' do
    include_context 'client'

    let(:hostnames) { ::Terraform::GroupHostnames.new }

    let(:resolved_attributes) { ::Terraform::GroupAttributes.new }

    let(:unresolved_attributes) { ::Terraform::GroupAttributes.new }

    before do
      allow(unresolved_attributes).to receive(:resolve).with client: client

      allow(hostnames)
        .to receive(:resolve).with(client: client).and_yield 'hostname'

      config_value
        .merge! attributes: unresolved_attributes, hostnames: hostnames
    end

    subject { ->(block) { described_instance.resolve client: client, &block } }

    it 'resolves output values and yields the group with a hostname' do
      is_expected.to yield_with_args hash_including(
        attributes: resolved_attributes, hostname: 'hostname'
      )
    end
  end
end
