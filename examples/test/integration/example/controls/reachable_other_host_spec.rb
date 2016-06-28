# frozen_string_literal: true

other_host_address = attribute 'other_host_address', {}

control 'reachable_other_host' do
  describe host other_host_address do
    it { is_expected.to be_reachable }
  end
end
