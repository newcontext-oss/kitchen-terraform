# frozen_string_literal: true

control 'nano_installed' do
  describe package 'nano' do
    it { is_expected.to be_installed }
  end
end
