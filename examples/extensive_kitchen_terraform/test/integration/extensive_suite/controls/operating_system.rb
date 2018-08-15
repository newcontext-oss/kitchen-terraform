# frozen_string_literal: true

instances_ami_operating_system_name = attribute(
  "instances_ami_operating_system_name",
  description: "The Terraform configuration under test must define the " \
  "equivalently named output",
)

control "operating_system" do
  desc "Verifies the name of the operating system on the targeted host"

  describe os.name do
    it { should eq instances_ami_operating_system_name }
  end
end
