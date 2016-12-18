control 'curl_installed' do
  describe package 'curl' do
    it { is_expected.to be_installed }
  end
end
