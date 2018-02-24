# frozen_string_literal: true

static_terraform_output =
  # The Terraform configuration under test must define the equivalently named
  # output
  attribute(
    "static_terraform_output",
    description: "An arbitrary, static output"
  )

customized_inspec_attribute =
  # The Test Kitchen configuration must map this attribute to the
  # 'static_terraform_output' output
  attribute(
    "customized_inspec_attribute",
    description: "A configured alias for static_terraform_output"
  )

control "inspec_attributes" do
  desc "A demonstration of how InSpec attributes are mapped to Terraform outputs"

  describe "The 'static_terraform_output' attribute" do
    subject do
      static_terraform_output
    end

    it "is mapped to the 'static_terraform_output' output by default" do
      is_expected.to eq "static terraform output"
    end
  end

  describe "The 'customized_inspec_attribute' attribute" do
    subject do
      customized_inspec_attribute
    end

    it "is mapped to the 'static_terraform_output' output by configuration" do
      is_expected.to eq "static terraform output"
    end
  end
end
