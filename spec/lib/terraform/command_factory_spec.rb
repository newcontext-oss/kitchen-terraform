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

require 'terraform/command_factory'
require 'support/terraform/configurable_context'

::RSpec.describe ::Terraform::CommandFactory do
  include_context 'instance'

  let(:described_instance) { described_class.new config: provisioner }

  before do
    provisioner[:color] = false
    provisioner[:directory] = ::Pathname.new '/directory'
    provisioner[:parallelism] = 1234
    provisioner[:plan] = ::Pathname.new '/plan/file'
    provisioner[:state] = ::Pathname.new '/state/file'
    provisioner[:variable_files] = [::Pathname.new('/variable/file')]
    provisioner[:variables] = { name: 'value' }
  end

  shared_examples 'a target is set' do
    subject { command.target.to_path }

    it('specifies a target') { is_expected.to eq target }
  end

  shared_examples 'color option' do
    it('is set from config[:color]') { is_expected.to include '-no-color' }
  end

  shared_examples 'destroy option' do
    it('is enabled') { is_expected.to include '-destroy=true' }
  end

  shared_examples 'input option' do
    it('is disabled') { is_expected.to include '-input=false' }
  end

  shared_examples 'options are specified' do
    subject { command.options.to_s }
  end

  shared_examples 'output command options' do
    it_behaves_like 'color option'

    it_behaves_like 'state option'
  end

  shared_examples 'parallelism option' do
    it 'is set from config[:parallelism]' do
      is_expected.to include '-parallelism=1234'
    end
  end

  shared_examples 'plan command options' do
    it_behaves_like 'color option'

    it_behaves_like 'input option'

    it_behaves_like 'parallelism option'

    it_behaves_like 'state option'

    it_behaves_like 'var option'

    it_behaves_like 'var-file option'

    it 'out option is set from config[:plan]' do
      is_expected.to include '-out=/plan/file'
    end
  end

  shared_examples 'state option' do
    it 'is set from config[:state]' do
      is_expected.to include '-state=/state/file'
    end
  end

  shared_examples 'state-out option' do
    it 'is set from config[:state]' do
      is_expected.to include '-state-out=/state/file'
    end
  end

  shared_examples 'var option' do
    it 'is set from config[:variables]' do
      is_expected.to include "-var='name=value'"
    end
  end

  shared_examples 'var-file option' do
    it 'is set from config[:variable_files]' do
      is_expected.to include '-var-file=/variable/file'
    end
  end

  describe '#apply_command' do
    let(:command) { described_instance.apply_command }

    it_behaves_like('a target is set') { let(:target) { '/plan/file' } }

    it_behaves_like 'options are specified' do
      it_behaves_like 'color option'

      it_behaves_like 'input option'

      it_behaves_like 'parallelism option'

      it_behaves_like 'state-out option'
    end
  end

  describe '#destructive_plan_command' do
    let(:command) { described_instance.destructive_plan_command }

    it_behaves_like('a target is set') { let(:target) { '/directory' } }

    it_behaves_like 'options are specified' do
      it_behaves_like 'destroy option'

      it_behaves_like 'plan command options'
    end
  end

  describe '#get_command' do
    let(:command) { described_instance.get_command }

    it_behaves_like('a target is set') { let(:target) { '/directory' } }

    it_behaves_like 'options are specified' do
      it('update option is enabled') { is_expected.to include '-update=true' }
    end
  end

  describe '#output_command' do
    let :command do
      described_instance
        .output_command target: ::Pathname.new('/target'),
                        version: ::Terraform::Version.create(value: version)
    end

    let(:version) { '0.7' }

    it_behaves_like('a target is set') { let(:target) { '/target' } }

    it_behaves_like 'options are specified' do
      context 'when the version does support JSON' do
        it_behaves_like 'output command options'

        it('json option is enabled') { is_expected.to include '-json=true' }
      end

      context 'when the version does not support JSON' do
        let(:version) { '0.6' }

        it_behaves_like 'output command options'

        it 'json option is not enabled' do
          is_expected.to_not include '-json=true'
        end
      end
    end
  end

  describe '#plan_command' do
    let(:command) { described_instance.plan_command }

    it_behaves_like('a target is set') { let(:target) { '/directory' } }

    it_behaves_like 'options are specified' do
      it_behaves_like 'plan command options'
    end
  end

  describe '#show_command' do
    let(:command) { described_instance.show_command }

    it_behaves_like('a target is set') { let(:target) { '/state/file' } }

    it_behaves_like('options are specified') { it_behaves_like 'color option' }
  end

  describe '#validate_command' do
    let(:command) { described_instance.validate_command }

    it_behaves_like('a target is set') { let(:target) { '/directory' } }
  end

  describe '#version_command' do
    subject { described_instance.version_command }

    it 'has no target or options' do
      is_expected.to be_instance_of ::Terraform::VersionCommand
    end
  end
end
