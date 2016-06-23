# frozen_string_literal: true

require 'terraform/plan_command'
require 'support/terraform/command_examples'

RSpec.describe Terraform::PlanCommand do
  it_behaves_like Terraform::Command do
    let :command_options do
      "-destroy=#{destroy} -input=false -out=#{out} " \
        "-state=#{state} -var=#{var} -var-file=#{var_file}"
    end

    let :described_instance do
      described_class.new destroy: destroy, out: out, state: state, var: var,
                          var_file: var_file, dir: target
    end

    let(:destroy) { true }

    let(:name) { 'plan' }

    let(:out) { '<plan_pathname>' }

    let(:state) { '<state_pathname>' }

    let(:target) { '<directory>' }

    let(:var) { '"foo=bar"' }

    let(:var_file) { '<variable_file>' }
  end
end
