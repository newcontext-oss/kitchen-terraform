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

require 'terraform/command_extender'

RSpec.shared_examples Terraform::CommandExtender do
  describe '#extend_behaviour(version:)' do
    let(:behaviour_module) { instance_double Object }

    let(:version_behaviours) { { /foo/ => behaviour_module } }

    before do
      allow(described_instance).to receive(:version_behaviours).with(no_args)
        .and_return version_behaviours
    end

    after { described_instance.extend_behaviour version: version }

    subject { described_instance }

    context 'when the version does have extra behaviour' do
      let(:version) { 'foo' }

      it 'does extend the command with the behaviour' do
        is_expected.to receive(:extend).with behaviour_module
      end
    end

    context 'when the version does not have extra behaviour' do
      let(:version) { 'bar' }

      it 'does not extend the command with any behaviour' do
        is_expected.to_not receive :extend
      end
    end
  end
end
