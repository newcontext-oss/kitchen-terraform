# frozen_string_literal: true

require "awspec"

reachable_other_host_id =
  # The Terraform configuration under test must define the equivalently named
  # output
  attribute(
    "reachable_other_host_id",
    description: "The ID of the AWS EC2 instance which should be reachable"
  )

control "reachable_other_host" do
  desc "Verifies that the other host is reachable from the current host"

  describe "The other host" do
    subject do
      # host is a resource provided by InSpec
      host(
        # ec2 is a resource provided by awspec
        ec2(reachable_other_host_id).public_ip_address
      )
    end

    before do
      sleep 5
    end

    it "is reachable" do
      is_expected.to be_reachable
    end
  end
end
