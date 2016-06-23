# frozen_string_literal: true

require 'terraform/client'

RSpec.shared_context '#client' do
  let(:client) { instance_double Terraform::Client }

  before do
    allow(described_instance).to receive(:client).with(no_args)
      .and_return client
  end
end
