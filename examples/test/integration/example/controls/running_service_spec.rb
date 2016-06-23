# frozen_string_literal: true

control 'running_service' do
  describe service 'cron' do
    it { is_expected.to be_running }
  end
end
