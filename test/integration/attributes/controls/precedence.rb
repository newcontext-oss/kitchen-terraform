# frozen_string_literal: true

# NOTE: this syntax should be valid until inspec v4.0.0
first_output = attribute("first_output", {})
second_output = attribute("second_output")

control "precedence" do
  title "precedence"
  desc "Tests to validate the precedence of overriding system attributes."

  describe attribute("output_first_output") do
    it { should eq "First Output" }
    it { should_not eq first_output }
  end

  describe first_output do
    it { should eq "From Attributes File" }
  end

  describe attribute("output_second_output") do
    it { should eq "Second Output" }
    it { should_not eq second_output }
  end

  describe second_output do
    it { should eq "Third Output" }
  end

  describe attribute("output_third_output") do
    it { should eq "First Output" }
    it { should_not eq attribute("third_output") }
  end

  describe attribute("third_output") do
    it { should eq "Third Output" }
  end

  describe attribute("input_passthrough") do
    it { should eq "value" }
  end
end
