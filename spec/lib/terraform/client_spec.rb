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
require 'terraform/client'
require 'terraform/command'

RSpec.describe Terraform::Client do
  let(:apply_timeout) { instance_double Object }

  let :described_instance do
    described_class.new instance_name: instance_name, logger: logger,
                                       provisioner: provisioner
  end

  let(:directory) { instance_double Object }

  let :instance_directory do
    "#{kitchen_root}/.kitchen/kitchen-terraform/#{instance_name}"
  end

  let(:instance_name) { '<instance_name>' }

  let(:kitchen_root) { '<kitchen_root>' }

  let(:logger) { instance_double Kitchen::Logger }

  let :provisioner do
    Kitchen::Provisioner::Terraform.new apply_timeout: apply_timeout,
                                        directory: directory,
                                        kitchen_root: kitchen_root,
                                        variable_files: variable_files,
                                        variables: variables
  end

  let(:variable_files) { instance_double Object }

  let(:variables) { instance_double Object }

  describe '#apply_execution_plan' do
    after { described_instance.apply_execution_plan }

    subject { described_instance }

    it 'applies the plan to the state' do
      is_expected.to receive(:run)
        .with command_class: Terraform::ApplyCommand, timeout: apply_timeout,
              state: described_instance.state_pathname,
              plan: described_instance.plan_pathname
    end
  end

  describe '#download_modules' do
    after { described_instance.download_modules }

    subject { described_instance }

    it 'downloads the modules required in the directory' do
      is_expected.to receive(:run).with command_class: Terraform::GetCommand,
                                        dir: directory
    end
  end

  describe '#extract_list_output(name:)' do
    let(:name) { instance_double Object }

    let(:output) { 'foo,bar' }

    before do
      allow(described_instance).to receive(:extract_output).with(name: name)
        .and_yield output
    end

    subject do
      ->(block) { described_instance.extract_list_output name: name, &block }
    end

    it 'splits and yields the extracted comma seperated output' do
      is_expected.to yield_with_args %w(foo bar)
    end
  end

  describe '#extract_output(name:)' do
    let(:name) { instance_double Object }

    let(:output) { "foo\n" }

    before do
      allow(described_instance).to receive(:run).with(
        command_class: Terraform::OutputCommand,
        state: described_instance.state_pathname, name: name
      ).and_yield output
    end

    subject do
      ->(block) { described_instance.extract_output name: name, &block }
    end

    it 'chomps and yields the extracted output from the state' do
      is_expected.to yield_with_args 'foo'
    end
  end

  describe '#instance_directory' do
    subject { described_instance.instance_directory.to_s }

    it { is_expected.to eq instance_directory }
  end

  describe '#plan_destructive_execution' do
    after { described_instance.plan_destructive_execution }

    subject { described_instance }

    it 'plans a destructive execution against the state' do
      is_expected.to receive(:run)
        .with command_class: Terraform::PlanCommand, destroy: true,
              out: described_instance.plan_pathname,
              state: described_instance.state_pathname, var: variables,
              var_file: variable_files, dir: directory
    end
  end

  describe '#plan_execution' do
    after { described_instance.plan_execution }

    subject { described_instance }

    it 'plans an execution against the state' do
      is_expected.to receive(:run)
        .with command_class: Terraform::PlanCommand, destroy: false,
              out: described_instance.plan_pathname,
              state: described_instance.state_pathname, var: variables,
              var_file: variable_files, dir: directory
    end
  end

  describe '#plan_pathname' do
    subject { described_instance.plan_pathname.to_s }

    it { is_expected.to eq "#{instance_directory}/terraform.tfplan" }
  end

  describe '#run(command_class:, **parameters)' do
    let(:command) { instance_double Terraform::Command }

    let(:command_class) { Class.new.include Terraform::Command }

    let(:output) { instance_double Object }

    let(:parameters) { { foo: 'bar' } }

    before do
      allow(command_class).to receive(:new).with(logger: logger, **parameters)
        .and_yield command

      allow(logger).to receive(:info).with command

      allow(command).to receive(:execute).with(no_args).and_yield output
    end

    subject do
      lambda do |block|
        described_instance.run command_class: command_class, **parameters,
                               &block
      end
    end

    it('yields the command output') { is_expected.to yield_with_args output }
  end

  describe '#state_pathname' do
    subject { described_instance.state_pathname.to_s }

    it { is_expected.to eq "#{instance_directory}/terraform.tfstate" }
  end

  describe '#supported_version' do
    subject { described_instance.supported_version }

    it('matches v0.6') { is_expected.to match 'v0.6' }
  end

  describe '#validate_configuration_files' do
    after { described_instance.validate_configuration_files }

    subject { described_instance }

    it 'validates the configuration files in the directory' do
      is_expected.to receive(:run)
        .with command_class: Terraform::ValidateCommand, dir: directory
    end
  end

  describe '#validate_version' do
    before do
      allow(described_instance).to receive(:run)
        .with(command_class: Terraform::VersionCommand).and_yield output
    end

    subject { proc { described_instance.validate_version } }

    context 'when the client does support the installed version of Terraform' do
      let(:output) { 'v0.6.7' }

      it('raises no error') { is_expected.to_not raise_error }
    end

    context 'when the client does not support the installed version of ' \
              'Terraform' do
      let(:output) { 'v0.7.8' }

      it 'raises a user error' do
        is_expected.to raise_error Terraform::UserError, /version must match/
      end
    end
  end
end
