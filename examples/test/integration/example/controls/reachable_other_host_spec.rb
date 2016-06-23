# frozen_string_literal: true

other_host = attribute 'hostname', {}

control 'reachable_other_host' do
  describe host other_host do
    it { is_expected.to be_reachable }
  end
end
