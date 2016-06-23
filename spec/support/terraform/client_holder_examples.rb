# frozen_string_literal: true

require 'terraform/client_holder'

RSpec.shared_examples Terraform::ClientHolder do
  describe '#client' do
    let(:instance) { instance_double Kitchen::Instance }

    before do
      allow(described_instance).to receive(:instance).with(no_args)
        .and_return instance

      allow(instance).to receive(:name).with no_args

      allow(instance).to receive(:provisioner).with no_args
    end

    subject { described_instance.client }

    it('is a Terraform client') { is_expected.to be_kind_of Terraform::Client }
  end
end
