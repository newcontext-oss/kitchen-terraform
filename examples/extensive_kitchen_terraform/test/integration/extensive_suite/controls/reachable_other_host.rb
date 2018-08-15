# frozen_string_literal: true

reachable_other_host_ip_address = attribute(
  "reachable_other_host_ip_address",
  description: "The Terraform configuration under test must define the " \
  "equivalently named output",
)

control "reachable_other_host" do
  desc "Verifies that the other host is reachable from the current host"

  describe host reachable_other_host_ip_address do
    it { should be_reachable }
  end
end
