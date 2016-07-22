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
  let(:described_instance) { described_class.new }

  describe '#add(targets:)' do
    let(:target) { instance_double Object }

    after { described_instance.add targets: [target] }

    subject { described_instance }

    it 'adds each target' do
      is_expected.to receive(:add_target).with target, described_instance.conf
    end
  end

  describe '#define_attribute(name:, value:)' do
    let(:name) { :name }

    let(:value) { instance_double Object }

    before { described_instance.define_attribute name: name, value: value }

    subject { described_instance.conf.fetch 'attributes' }

    it 'defines an attribute on the runner' do
      is_expected.to include 'name' => value
    end
  end

  describe '#verify_run(verifier:)' do
    let(:exit_code) { instance_double Object }

    let(:verifier) { instance_double Kitchen::Verifier::Terraform }

    before do
      allow(described_instance).to receive(:run).with(no_args)
        .and_return exit_code
    end

    after { described_instance.verify_run verifier: verifier }

    subject { verifier }

    it 'verifies the exit code after running' do
      is_expected.to receive(:evaluate).with exit_code: exit_code
    end
  end
end
