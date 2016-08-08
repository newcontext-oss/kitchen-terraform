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

require 'kitchen/driver/terraform'
require 'support/terraform/configurable_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Driver::Terraform do
  include_context '#provisioner'

  let(:described_instance) { described_class.new }

  it_behaves_like Terraform::Configurable

  it_behaves_like 'versions are set'

  describe '.serial_actions' do
    subject(:serial_actions) { described_class.serial_actions }

    it('is empty') { is_expected.to be_empty }
  end

  describe '#create(_state = nil)' do
    subject { provisioner }

    after { described_instance.create }

    it 'validates the installed version of Terraform' do
      is_expected.to receive(:validate_version).with no_args
    end
  end

  describe '#destroy(_state = nil)' do
    let(:apply_execution_plan) { receive(:apply_execution_plan).with no_args }

    let(:download_modules) { receive(:download_modules).with no_args }

    let :plan_destructive_execution do
      receive(:plan_destructive_execution).with no_args
    end

    let :validate_configuration_files do
      receive(:validate_configuration_files).with no_args
    end

    before do
      allow(provisioner).to validate_configuration_files

      allow(provisioner).to download_modules

      allow(provisioner).to plan_destructive_execution

      allow(provisioner).to apply_execution_plan
    end

    after { described_instance.destroy }

    subject { provisioner }

    it 'validates the configuration files' do
      is_expected.to validate_configuration_files
    end

    it('gets the modules') { is_expected.to download_modules }

    it 'plans the destructive execution' do
      is_expected.to plan_destructive_execution
    end
<<<<<<< b9dafad12a2874ff348bbbe9be99ab2c7c5c696d

    it('applies the execution plan') { is_expected.to apply_execution_plan }
=======
>>>>>>> Move version validation logic to client
  end
end
