# frozen_string_literal: true

terraform_state = attribute(
  "terraform_state",
  description: "The Terraform configuration under test must define the " \
  "equivalently named output",
).chomp

control "state_file" do
  desc "Verifies that the Terraform state file can be used in InSpec controls"

  describe json(terraform_state).terraform_version do
    it { should match /\d+\.\d+\.\d+/ }
  end
end
