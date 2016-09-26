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

require 'kitchen/verifier/terraform'
require 'terraform/inspec_runner'

RSpec.describe Terraform::InspecRunner do
  let(:conf) { {} }

  let(:described_instance) { described_class.new conf }

  describe '#add(target:)' do
    let(:target) { instance_double Object }

    before do
      allow(described_instance).to receive(:conf).with(no_args).and_return conf
    end

    after { described_instance.add target: target }

    subject { described_instance }

    it 'adds the target' do
      is_expected.to receive(:add_target).with target, conf
    end
  end

  describe '#evaluate(verifier:)' do
    let(:add_targets) { receive(:add_targets).with runner: described_instance }

    let(:attributes) { {} }

    let(:call_method) { described_instance.evaluate verifier: verifier }

    let(:exit_code) { instance_double Object }

    let(:key) { instance_double Object }

    let(:value) { instance_double Object }

    let(:verifier) { instance_double Kitchen::Verifier::Terraform }

    let(:verify) { receive(:verify).with exit_code: exit_code }

    before do
      conf[:attributes] = attributes

      allow(verifier).to add_targets

      allow(described_instance).to receive(:run).with(no_args)
        .and_return exit_code

      allow(verifier).to verify
    end

    after { call_method }

    subject { verifier }

    it('adds the targets of the verifier') { is_expected.to add_targets }

    it('verifies the exit code') { is_expected.to verify }
  end
end
