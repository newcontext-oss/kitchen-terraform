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

require 'kitchen/verifier/terraform'
require 'inspec/runner'
require 'support/terraform/configurable_context'
require 'support/terraform/configurable_examples'
require 'support/terraform/groups_config_examples'
require 'terraform/group'

::RSpec.describe ::Kitchen::Verifier::Terraform do
  include_context 'config'

  let(:described_instance) { described_class.new config }

  shared_context '#add_targets' do
    before do
      allow(described_instance).to receive(:collect_tests)
        .with(no_args).and_return []
    end
  end

  shared_context '#execute' do
    include_context '#add_targets'

    let(:runner) { instance_double ::Inspec::Runner }

    before do
      allow(::Inspec::Runner).to receive(:new)
        .with(hash_including(options)).and_return runner

      allow(runner).to receive(:run).with(no_args).and_return exit_code
    end
  end

  shared_context '#resolve_attributes' do
    include_context '#driver'

    before do
      allow(driver).to receive(:each_output_name)
        .with(no_args).and_yield 'default_attribute_name'

      allow(driver).to receive(:output_value)
        .with(name: 'default_attribute_name')
        .and_return 'resolved_default_output_value'

      allow(driver).to receive(:output_value)
        .with(name: 'provided_output_name')
        .and_return 'resolved_provided_output_value'
    end
  end

  shared_context '#verify' do
    include_context '#execute'

    include_context '#resolve_attributes'
  end

  shared_context '#verify_groups' do
    include_context '#verify'

    let :group do
      ::Terraform::Group.new data: {
        attributes: { provided_attribute_name: 'provided_output_name' },
        controls: ['control'], hostnames: hostnames, port: 1234, user: 'user'
      }
    end

    before { allow(config).to receive(:[]).with(:groups).and_return [group] }
  end

  shared_examples '#validate' do
    let(:runner_options) { { runner_key: 'runner_value' } }

    let(:state) { instance_double ::Object }

    before do
      allow(described_instance).to receive(:runner_options)
        .with(transport, state).and_return runner_options
    end

    subject { proc { described_instance.call state } }

    context 'when the value is zero' do
      let(:exit_code) { 0 }

      it('takes no action') { is_expected.to_not raise_error }
    end

    context 'when the value is not zero' do
      let(:exit_code) { 1234 }

      it 'raises an instance failure' do
        is_expected.to raise_error ::Kitchen::InstanceFailure, /1234/
      end
    end
  end

  it_behaves_like ::Terraform::Configurable

  it_behaves_like ::Terraform::GroupsConfig

  describe '#call(state)' do
    include_context '#logger'

    include_context '#transport'

    include_context '#verify_groups'

    context 'when the group is local' do
      let(:hostnames) { '' }

      let :options do
        {
          attributes: {
            'default_attribute_name' => 'resolved_default_output_value',
            'provided_attribute_name' => 'resolved_provided_output_value'
          },
          backend: 'local', controls: ['control'], runner_key: 'runner_value'
        }
      end

      it_behaves_like '#validate'
    end

    context 'when the group is remote' do
      let(:hostnames) { 'unresolved_hostnames' }

      let :options do
        {
          attributes: {
            'default_attribute_name' => 'resolved_default_output_value',
            'provided_attribute_name' => 'resolved_provided_output_value'
          },
          controls: ['control'], host: 'resolved_hostname',
          runner_key: 'runner_value'
        }
      end

      before do
        allow(driver).to receive(:output_value)
          .with(list: true, name: 'unresolved_hostnames')
          .and_yield 'resolved_hostname'
      end

      it_behaves_like '#validate'
    end
  end
end
