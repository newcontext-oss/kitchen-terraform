# frozen_string_literal: true

instances_ami_operating_system_name =
  # The Terraform configuration under test must define the equivalently named
  # output
  attribute(
    "instances_ami_operating_system_name",
    description: "The name of the operating system on the AWS EC2 instances AMI"
  )

control "operating_system" do
  desc "Verifies the name of the operating system on the targeted host"

  describe "The operating system name" do
    subject do
      os[:name]
    end

    it "is equal to the 'instances_ami_operating_system_name' output" do
      is_expected.to eq instances_ami_operating_system_name
    end
  end
end
