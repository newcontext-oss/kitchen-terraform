# frozen_string_literal: true

first_attribute = attribute "first",
                            default: "first_attrs.yml was not loaded",
                            description: "This value should be loaded from test/integration/example/first_attrs.yml."

second_attribute = attribute "second",
                             default: "second_attrs.yml was not loaded",
                             description: "This value should be loaded from test/integration/example/second_attrs.yml."

control "attrs" do
  desc "This control validates that the elements of the verifier.systems.x.attrs attribute are successfully passed " \
       "to InSpec as attrs."

  describe first_attribute do
    it do
      should eq "first_attrs.yml was loaded"
    end
  end

  describe second_attribute do
    it do
      should eq "second_attrs.yml was loaded"
    end
  end
end
