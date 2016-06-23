# frozen_string_literal: true

require 'terraform/output_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::OutputCommand do
  let(:described_instance) { described_class.new state: state, name: target }

  let(:state) { '<state_pathname>' }

  let(:target) { '<name>' }

  it_behaves_like Terraform::Command do
    let(:command_options) { "-state=#{state}" }

    let(:name) { 'output' }
  end

  describe '#handle(error:)' do
    let(:error) { instance_double Exception }

    before do
      allow(error).to receive(:message).with(no_args).and_return message

      allow(error).to receive(:backtrace).with no_args
    end

    subject { proc { described_instance.handle error: error } }

    context 'when the error message does match the pattern' do
      let(:message) { 'nothing to output' }

      it 'does raise an error' do
        is_expected.to raise_error Terraform::OutputNotFound
      end
    end

    context 'when the error message does not match the pattern' do
      let(:message) { 'a thing to output' }

      it('does not raise an error') { is_expected.to_not raise_error }
    end
  end
end
