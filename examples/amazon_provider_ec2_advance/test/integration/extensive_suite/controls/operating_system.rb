# frozen_string_literal: true

operating_system_name =
  attribute(
    "instances_ami_operating_system_name",
    description:
      "instances_ami_operating_system_name is expected to be the name of an output of the Terraform configuration " \
        "under test"
  )

control "operating_system" do
  desc "This control verifies the name of the operating system of the targeted host"

  describe "the operating system name" do
    subject do
      os[:name]
    end

    it do
      is_expected.to eq instances_ami_operating_system_name
    end
  end
end
