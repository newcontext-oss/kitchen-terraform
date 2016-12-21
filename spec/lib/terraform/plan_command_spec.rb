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

require 'terraform/plan_command'
require 'support/terraform/color_switch_context'
require 'support/terraform/color_switch_examples'

RSpec.describe Terraform::PlanCommand do
  let(:color) { instance_double Object }

  let :described_instance do
    described_class.new color: color, destroy: destroy, out: out, state: state,
                        variables: variables, variable_files: [variable_file]
  end

  let(:destroy) { instance_double Object }

  let(:out) { instance_double Object }

  let(:state) { instance_double Object }

  let(:variable_file) { instance_double Object }

  let(:variables) { { 'key' => 'value' } }

  it_behaves_like Terraform::ColorSwitch

  describe '#name' do
    subject { described_instance.name }

    it('returns "plan"') { is_expected.to eq 'plan' }
  end

  describe '#options' do
    include_context '#color_switch'

    subject { described_instance.options }

    it 'returns "-destroy=<true_or_false> -input=false ' \
         '-out=<plan_pathname> -state=<state_pathname> ' \
         '-color=<true or false> [-var=\'<variable_assignment>\'...] ' \
         '[-var-file=<variable_pathname>...]"' do
      is_expected.to eq "-destroy=#{destroy} -input=false -out=#{out} " \
                          "-state=#{state} -color=<true or false> " \
                          "-var='key=value' -var-file=#{variable_file}"
    end
  end
end
