# frozen_string_literal: true

reachable_other_host_id =
  attribute(
    "reachable_other_host_id",
    description:
      "reachable_other_host is expected to be the name of an output of the Terraform configuration under test"
  )

control "reachable_other_host" do
  desc "This control verifies that the other host is reachable from the current host"

  describe "the other host" do
    subject do
      host aws_ec2_instance(reachable_other_host_id).public_ip_address
    end

    it do
      is_expected.to be_reachable
    end
  end
end
