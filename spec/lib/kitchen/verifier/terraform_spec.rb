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

  shared_context '#resolve_attributes' do
    include_context '#driver'

    before do
      allow(driver).to receive(:output_value)
        .with(name: 'unresolved_attribute_value')
        .and_return 'resolved_attribute_value'
    end
  end

  shared_context '#verify_groups' do
    include_context '#resolve_attributes'

    let :group do
      ::Terraform::Group.new data: {
        attributes: { attribute_key: 'unresolved_attribute_value' },
        controls: ['control'], hostnames: hostnames, port: 1234, user: 'user'
      }
    end

    before { allow(config).to receive(:[]).with(:groups).and_return [group] }
  end

  it_behaves_like ::Terraform::Configurable

  it_behaves_like ::Terraform::GroupsConfig

  describe '#call(state)' do
    include_context '#logger'

    include_context '#transport'

    include_context '#verify_groups'

    shared_examples 'exit code validator' do
      let(:output_names) { instance_double Array }

      let(:output_value) { instance_double Object }

      let(:runner) { instance_double ::Inspec::Runner }

      let(:runner_options) { { runner_key: 'runner_value' } }

      let(:state) { instance_double ::Object }

      before do
        allow(driver).to receive(:each_output_name).with(no_args)
          .and_yield output_name

        allow(group).to receive(:store_attribute)
          .with(key: output_name, value: output_name)

        allow(group).to receive(:store_attribute)
          .with(key: key, value: output_value)

        allow(group).to receive(:each_attribute).with(no_args)
          .and_yield(key, output_name)

        allow(described_instance).to receive(:runner_options)
          .with(transport, state).and_return runner_options

        allow(::Inspec::Runner).to receive(:new)
          .with(hash_including(options)).and_return runner

        allow(described_instance).to receive(:collect_tests)
          .with(no_args).and_return []

        allow(runner).to receive(:run).with(no_args).and_return exit_code
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

    context 'when the group is local' do
      let(:hostnames) { '' }

      let :options do
        {
          attributes: { 'attribute_key' => 'resolved_attribute_value' },
          backend: 'local', controls: ['control'], runner_key: 'runner_value'
        }
      end

      it_behaves_like 'exit code validator'
    end

    context 'when the group is remote' do
      let(:hostnames) { 'unresolved_hostnames' }

      let :options do
        {
          attributes: { 'attribute_key' => 'resolved_attribute_value' },
          controls: ['control'], host: 'resolved_hostname',
          runner_key: 'runner_value'
        }
      end

      before do
        allow(driver).to receive(:output_value)
          .with(list: true, name: 'unresolved_hostnames')
          .and_yield 'resolved_hostname'
      end

      it_behaves_like 'exit code validator'
    end
  end
end
