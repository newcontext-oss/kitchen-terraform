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

require 'terraform/command_factory'
require 'support/terraform/apply_command_examples'
require 'support/terraform/configurable_context'
require 'support/terraform/destructive_plan_command_examples'
require 'support/terraform/get_command_examples'
require 'support/terraform/output_command_examples'
require 'support/terraform/plan_command_examples'
require 'support/terraform/show_command_examples'
require 'support/terraform/validate_command_examples'
require 'support/terraform/version_command_examples'

::RSpec.describe ::Terraform::CommandFactory do
  include_context 'instance'

  let(:factory) { described_class.new config: provisioner }

  before do
    provisioner[:color] = false
    provisioner[:variable_files] = ['variable/file']
    provisioner[:variables] = { variable_name: 'variable_value' }
  end

  describe '#apply_command' do
    it_behaves_like ::Terraform::ApplyCommand do
      let(:described_instance) { factory.apply_command }
    end
  end

  describe '#destructive_plan_command' do
    it_behaves_like ::Terraform::DestructivePlanCommand do
      let(:described_instance) { factory.destructive_plan_command }
    end
  end

  describe '#get_command' do
    it_behaves_like ::Terraform::GetCommand do
      let(:described_instance) { factory.get_command }
    end
  end

  describe '#json_output_command' do
    it_behaves_like ::Terraform::OutputCommand do
      let(:described_instance) { factory.json_output_command target: object }

      describe '#options' do
        subject { described_instance.options.to_s }

        it('include -json=true') { is_expected.to include '-json=true' }
      end
    end
  end

  describe '#output_command' do
    it_behaves_like ::Terraform::OutputCommand do
      let(:described_instance) { factory.output_command target: object }
    end
  end

  describe '#plan_command' do
    it_behaves_like ::Terraform::PlanCommand do
      let(:described_instance) { factory.plan_command }
    end
  end

  describe '#show_command' do
    it_behaves_like ::Terraform::ShowCommand do
      let(:described_instance) { factory.show_command }
    end
  end

  describe '#validate_command' do
    it_behaves_like ::Terraform::ValidateCommand do
      let(:described_instance) { factory.validate_command }
    end
  end

  describe '#version_command' do
    it_behaves_like ::Terraform::VersionCommand do
      let(:described_instance) { factory.version_command }
    end
  end
end
