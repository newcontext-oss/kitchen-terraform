# frozen_string_literal: true

require 'terraform/apply_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::ApplyCommand do
  it_behaves_like Terraform::Command do
    let(:command_options) { "-input=false -state=#{state}" }

    let(:described_instance) { described_class.new state: state, plan: target }

    let(:name) { 'apply' }

    let(:state) { '<state_pathname>' }

    let(:target) { '<plan_pathname>' }
  end
end
