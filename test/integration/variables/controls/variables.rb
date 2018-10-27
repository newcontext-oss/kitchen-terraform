# frozen_string_literal: true

control "variables" do
  variables = ::File.expand_path ::File.join("..", "..", "..", "..", "terraform", "variables"), __FILE__

  describe file ::File.join variables, "variable.txt" do
    its("content") { should eq "abc" }
  end
end
