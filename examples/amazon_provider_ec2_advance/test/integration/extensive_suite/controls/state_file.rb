# frozen_string_literal: true

terraform_state =
  # The Terraform configuration under test must define the equivalently named
  # output
  attribute(
    "terraform_state",
    description: "The path to the Terraform state file"
  )
    .chomp

control "state_file" do
  desc "Verifies that the Terraform state file can be used in InSpec controls"

  describe "The Terraform version in the Terraform state file" do
    subject do
      json(terraform_state).terraform_version
    end

    it "matches the MAJOR.MINOR.PATCH format" do
      is_expected.to match /\d+\.\d+\.\d+/
    end
  end
end
