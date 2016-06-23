# frozen_string_literal: true

require 'terraform/get_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::GetCommand do
  it_behaves_like Terraform::Command do
    let(:command_options) { '-update=true' }

    let(:described_instance) { described_class.new dir: target }

    let(:name) { 'get' }

    let(:target) { '<directory>' }
  end
end
