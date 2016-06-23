# frozen_string_literal: true

require 'terraform/validate_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::ValidateCommand do
  it_behaves_like Terraform::Command do
    let(:command_options) { '' }

    let(:described_instance) { described_class.new dir: target }

    let(:name) { 'validate' }

    let(:target) { '<directory>' }
  end
end
