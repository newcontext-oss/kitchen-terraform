# frozen_string_literal: true

control "variables" do
  variables = ::File.expand_path ::File.join("..", "..", "..", "..", "terraform", "variables"), __FILE__

  describe file ::File.join variables, "string.txt" do
    its("content") { should eq "A String" }
  end

  describe file ::File.join variables, "map.txt" do
    its("content") { should eq "A Value" }
  end

  describe file ::File.join variables, "list.txt" do
    its("content") { should eq "Element One; Element Two" }
  end
end
