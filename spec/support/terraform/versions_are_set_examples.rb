# frozen_string_literal: true

require 'terraform/version'

RSpec.shared_examples 'versions are set' do
  describe '@api_version' do
    subject :api_version do
      described_class.instance_variable_get :@api_version
    end

    it('equals 2') { is_expected.to eq 2 }
  end

  describe '@plugin_version' do
    subject :plugin_version do
      described_class.instance_variable_get :@plugin_version
    end

    it('equals the gem version') { is_expected.to be Terraform::VERSION }
  end
end
