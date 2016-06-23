# frozen_string_literal: true

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
