# frozen_string_literal: true

terraform_state =
  attribute(
    "terraform_state",
    description: "terraform_state is expected to be the name of an output of the Terraform configuration under test"
  )

control "state_file" do
  desc "This control verifies that the Terraform state file can be used in InSpec controls"

  describe "the Terraform version in the Terraform state file" do
    subject do
      json(terraform_state).terraform_version
    end

    it do
      is_expected.to match /\d+\.\d+\.\d+/
    end
  end
end
