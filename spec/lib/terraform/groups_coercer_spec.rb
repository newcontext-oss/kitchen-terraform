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

require 'terraform/groups_coercer'
require 'support/raise_error_examples'
require 'support/terraform/configurable_context'

::RSpec.describe ::Terraform::GroupsCoercer do
  include_context 'instance'

  let(:described_instance) { described_class.new configurable: provisioner }

  describe '#coerce' do
    let(:call_method) { described_instance.coerce attr: :attr, value: value }

    context 'when the value is a valid list of group mappings' do
      shared_examples 'it has a dynamic default' do
        let :transport do
          ::Kitchen::Transport::Ssh.new property => transport_property_value
        end

        before { call_method }

        subject { ->(block) { provisioner[:attr].map(&property).each(&block) } }

        context 'when the group property is specified' do
          let :value do
            [
              { name: 'name1', property => group_property_value },
              { name: 'name2', property => group_property_value }
            ]
          end

          it 'uses the specified value' do
            is_expected.to yield_successive_args group_property_value,
                                                 group_property_value
          end
        end

        context 'when the group property is not specified' do
          let(:value) { [{ name: 'name1' }, { name: 'name2' }] }

          it 'uses the transport value' do
            is_expected.to yield_successive_args transport_property_value,
                                                 transport_property_value
          end
        end
      end

      describe 'each group mapping port' do
        it_behaves_like 'it has a dynamic default' do
          let(:group_property_value) { 2468 }

          let(:property) { :port }

          let(:transport_property_value) { 3579 }
        end
      end

      describe 'each group mapping username' do
        it_behaves_like 'it has a dynamic default' do
          let(:group_property_value) { 'username' }

          let(:property) { :username }

          let(:transport_property_value) { 'default_username' }
        end
      end
    end

    context 'when the value is not a valid list of group mappings' do
      let(:value) { { name: 'name' } }

      it_behaves_like 'a user error has occurred' do
        let(:described_method) { call_method }

        let(:message) { /:attr.*a list of group mappings/ }
      end
    end
  end
end
