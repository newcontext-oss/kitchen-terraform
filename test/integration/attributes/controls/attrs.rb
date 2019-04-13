# frozen_string_literal: true

# NOTE: this syntax should be valid until inspec v4.0.0
first_output = attribute("first_output", {})
second_output = attribute("second_output")

control "attrs" do
  title "attrs"
  desc "Tests to validate the behaviour of the attrs system key."

  describe attribute("output_first_output") do
    it { should eq "First Output" }
    it { should_not eq first_output }
  end

  describe first_output do
    it { should eq "From Attributes File" }
  end

  describe attribute("output_second_output") do
    it { should eq "Second Output" }
    it { should eq second_output }
  end

  describe attribute("output_third_output") do
    it { should eq "Third Output" }
    it { should eq attribute("third_output") }
  end

  describe attribute("input_passthrough") do
    it { should eq "value" }
  end
end
