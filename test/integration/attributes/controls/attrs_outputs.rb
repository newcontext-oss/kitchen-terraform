# frozen_string_literal: true

first_output = attribute "first_output", {}
second_output = attribute "second_output", {}
third_output = attribute "third_output", {}

control "attrs_outputs" do
  describe first_output do
    it { should eq "Second Output" }
  end

  describe second_output do
    it { should eq "Second Output" }
  end

  describe third_output do
    it { should eq "Third Output" }
  end
end
