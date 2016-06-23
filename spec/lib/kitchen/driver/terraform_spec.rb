# frozen_string_literal: true

require 'kitchen/driver/terraform'
require 'terraform/error'
require 'support/terraform/client_holder_context'
require 'support/terraform/client_holder_examples'
require 'support/terraform/versions_are_set_examples'

RSpec.describe Kitchen::Driver::Terraform do
  let(:described_instance) { described_class.new }

  it_behaves_like Terraform::ClientHolder

  it_behaves_like 'versions are set'

  describe '.serial_actions' do
    subject(:serial_actions) { described_class.serial_actions }

    it('is empty') { is_expected.to be_empty }
  end

  describe '#create(_state = nil)' do
    include_context '#client'

    before do
      allow(client).to receive(:fetch_version).with(no_args).and_yield output
    end

    subject { proc { described_instance.create } }

    context 'when the Terraform version is supported' do
      let(:output) { 'v0.6.1' }

      it('does not raise an error') { is_expected.to_not raise_error }
    end

    context 'when the Terraform version is not supported' do
      let(:output) { 'v0.5.2' }

      it 'does raise an error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end

    context 'when the client command fails' do
      before do
        allow(client).to receive(:fetch_version).with(no_args)
          .and_raise Terraform::Error
      end

      it 'does raise an error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end
  end

  describe '#destroy(_state = nil)' do
    include_context '#client'

    let(:call_method) { described_instance.destroy }

    context 'when the Terraform state can be destroyed' do
      before do
        allow(client).to receive(:validate_configuration_files).with no_args

        allow(client).to receive(:download_modules).with no_args

        allow(client).to receive(:plan_destructive_execution).with no_args

        allow(client).to receive(:apply_execution_plan).with no_args
      end

      after { call_method }

      subject { client }

      it 'validates the configuration files' do
        is_expected.to receive(:validate_configuration_files).with no_args
      end

      it 'gets the modules' do
        is_expected.to receive(:download_modules).with no_args
      end

      it 'plans the destructive execution' do
        is_expected.to receive(:plan_destructive_execution).with no_args
      end

      it 'applies the execution plan' do
        is_expected.to receive(:apply_execution_plan).with no_args
      end
    end

    context 'when a client command fails' do
      before do
        allow(client).to receive(:validate_configuration_files).and_raise
      end

      subject { proc { call_method } }

      it 'raises an error' do
        is_expected.to raise_error Kitchen::ActionFailed
      end
    end
  end

  describe '#supported_version' do
    subject { described_instance.supported_version }

    it('equals v0.6') { is_expected.to eq 'v0.6' }
  end
end
