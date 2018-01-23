# frozen_string_literal: true

static_terraform_output =
  attribute(
    "static_terraform_output",
    description:
      "static_terraform_output is expected to be the name of an output of the Terraform configuration under test"
  )

customized_inspec_attribute =
  attribute(
    "customized_inspec_attribute",
    description: "customized_inspec_attribute is expected to be an alias for static_terraform_output"
  )

control "inspec_attributes" do
  desc "This control demonstrates how InSpec attributes are mapped to Terraform outputs"

  describe "the value of the 'static_terraform_output' Terraform output" do
    subject do
      'static terraform output'
    end

    it "is mapped to the 'static_terraform_output' InSpec attribute by default" do
      is_expected.to eq static_terraform_output
    end

    it "is mapped to the 'customized_inspec_attribute' attribute by configuration" do
      is_expected.to eq customized_inspec_attribute
    end
  end
end
