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

require 'kitchen/provisioner/terraform'
require 'support/terraform/apply_timeout_config_examples'
require 'support/terraform/color_config_examples'
require 'support/terraform/configurable_context'
require 'support/terraform/configurable_examples'
require 'support/terraform/directory_config_examples'
require 'support/terraform/plan_config_examples'
require 'support/terraform/state_config_examples'
require 'support/terraform/variable_files_config_examples'
require 'support/terraform/variables_config_examples'

RSpec.describe Kitchen::Provisioner::Terraform do
  include_context 'config'

  let(:described_instance) { described_class.new config }

  it_behaves_like Terraform::ApplyTimeoutConfig

  it_behaves_like Terraform::ColorConfig

  it_behaves_like Terraform::Configurable

  it_behaves_like Terraform::DirectoryConfig

  it_behaves_like Terraform::PlanConfig

  it_behaves_like Terraform::StateConfig

  it_behaves_like Terraform::VariableFilesConfig

  it_behaves_like Terraform::VariablesConfig

  describe '#call(_state = nil)' do
    include_context '#driver'

    let(:apply_execution_plan) { receive(:apply_execution_plan).with no_args }

    let(:download_modules) { receive(:download_modules).with no_args }

    let :plan_constructive_execution do
      receive(:plan_execution).with destroy: false
    end

    let :validate_configuration_files do
      receive(:validate_configuration_files).with no_args
    end

    before do
      allow(driver).to validate_configuration_files

      allow(driver).to download_modules

      allow(driver).to plan_constructive_execution

      allow(driver).to apply_execution_plan
    end

    after { described_instance.call }

    subject { driver }

    it 'validates the configuration files' do
      is_expected.to validate_configuration_files
    end

    it('downloads the dependency modules') { is_expected.to download_modules }

    it 'plans a constructive execution' do
      is_expected.to plan_constructive_execution
    end

    it 'applys the constructive execution plan' do
      is_expected.to apply_execution_plan
    end
  end
end
