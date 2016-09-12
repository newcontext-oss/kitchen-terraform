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
require 'terraform/group'
require 'terraform/inspec_runner'

RSpec.describe Terraform::InspecRunner do
  let(:described_instance) { described_class.new attributes: {} }

  describe '.run_and_verify(group:, options:, verifier:)' do
    let(:exit_code) { instance_double Object }

    let(:group) { instance_double Terraform::Group }

    let(:instance) { instance_double described_class }

    let(:options) { { 'biz' => 'baz' } }

    let(:tests) { instance_double Object }

    let(:verifier) { instance_double Kitchen::Verifier::Terraform }

    before do
      allow(described_class).to receive(:new).with(options).and_return instance

      allow(group).to receive(:populate).with runner: instance

      allow(verifier).to receive(:populate).with runner: instance

      allow(instance).to receive(:run).with(no_args).and_return exit_code

      allow(verifier).to receive(:evaluate).with exit_code: exit_code
    end

    after do
      described_class.run_and_verify group: group, options: options,
                                     verifier: verifier
    end

    subject { verifier }

    it 'populates the runner with the verifier tests' do
      is_expected.to receive(:populate).with runner: instance
    end

    it 'evaluates the exit code from the runner' do
      is_expected.to receive(:evaluate).with exit_code: exit_code
    end
  end

  describe '#add(target:)' do
    let(:conf) { instance_double Object }

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

  describe '#set_attribute(key:, value:)' do
    before { described_instance.set_attribute key: :key, value: :value }

    subject { described_instance.conf[:attributes] }

    it 'stores the attribute pair with a string key' do
      is_expected.to include 'key' => :value
    end
  end
end
