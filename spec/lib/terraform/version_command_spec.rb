# frozen_string_literal: true

require 'terraform/version_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::VersionCommand do
  it_behaves_like Terraform::Command do
    let(:command_options) { '' }

    let(:described_instance) { described_class.new }

    let(:name) { 'version' }

    let(:target) { '' }
  end
end
