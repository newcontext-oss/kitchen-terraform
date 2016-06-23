# frozen_string_literal: true

require 'terraform/command_options'

RSpec.describe Terraform::CommandOptions do
  describe '#to_s' do
    let :described_instance do
      described_class.new single_argument: 'argument',
                          multiple_arguments: %w(argument argument)
    end

    subject { described_instance.to_s }

    it 'transform the options in to flags' do
      is_expected.to eq '-single-argument=argument ' \
                          '-multiple-arguments=argument ' \
                          '-multiple-arguments=argument'
    end
  end
end
