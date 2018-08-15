# frozen_string_literal: true

static_terraform_output = attribute(
  "static_terraform_output",
  description: "The Terraform configuration under test must define an " \
  "equivalently named output",
)

customized_inspec_attribute = attribute(
  "customized_inspec_attribute",
  description: "The Test Kitchen configuration must map this attribute to the " \
  "'static_terraform_output' output",
)

control "inspec_attributes" do
  desc "A demonstration of how InSpec attributes are mapped to Terraform outputs"

  describe static_terraform_output do
    it { should eq "static terraform output" }
  end

  describe customized_inspec_attribute do
    it { should eq "static terraform output" }
  end
end
