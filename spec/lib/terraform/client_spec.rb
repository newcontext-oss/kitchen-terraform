# frozen_string_literal: true

require 'kitchen/provisioner/terraform'
require 'terraform/client'
require 'terraform/command'

RSpec.describe Terraform::Client do
  let(:described_instance) { described_class.new instance: instance }

  let(:instance) { instance_double Kitchen::Instance }

  let :instance_directory do
    "#{kitchen_root}/.kitchen/kitchen-terraform/#{instance_name}"
  end

  let(:instance_name) { '<instance_name>' }

  let(:kitchen_root) { '<kitchen_root>' }

  let :provisioner do
    Kitchen::Provisioner::Terraform.new kitchen_root: kitchen_root
  end

  before do
    allow(instance).to receive(:name).with(no_args).and_return instance_name

    allow(instance).to receive(:provisioner).with(no_args)
      .and_return provisioner
  end

  describe '#apply_execution_plan' do
    after { described_instance.apply_execution_plan }

    subject { described_instance }

    it 'applies the plan to the state' do
      is_expected.to receive(:run)
        .with command_class: Terraform::ApplyCommand,
              state: described_instance.state_pathname,
              plan: described_instance.plan_pathname
    end
  end

  describe '#download_modules' do
    after { described_instance.download_modules }

    subject { described_instance }

    it 'downloads the modules required in the directory' do
      is_expected.to receive(:run).with command_class: Terraform::GetCommand,
                                        dir: described_instance.directory
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

  describe '#fetch_version' do
    let(:output) { instance_double Object }

    before do
      allow(described_instance).to receive(:run)
        .with(command_class: Terraform::VersionCommand).and_yield output
    end

    subject { ->(block) { described_instance.fetch_version(&block) } }

    it 'yields the Terraform version' do
      is_expected.to yield_with_args output
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
              state: described_instance.state_pathname,
              var: described_instance.variables,
              var_file: described_instance.variable_files,
              dir: described_instance.directory
    end
  end

  describe '#plan_execution' do
    after { described_instance.plan_execution }

    subject { described_instance }

    it 'plans an execution against the state' do
      is_expected.to receive(:run)
        .with command_class: Terraform::PlanCommand, destroy: false,
              out: described_instance.plan_pathname,
              state: described_instance.state_pathname,
              var: described_instance.variables,
              var_file: described_instance.variable_files,
              dir: described_instance.directory
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
      allow(command_class).to receive(:new).with(**parameters)
        .and_yield command

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

  describe '#validate_configuration_files' do
    after { described_instance.validate_configuration_files }

    subject { described_instance }

    it 'validates the configuration files in the directory' do
      is_expected.to receive(:run)
        .with command_class: Terraform::ValidateCommand,
              dir: described_instance.directory
    end
  end
end
