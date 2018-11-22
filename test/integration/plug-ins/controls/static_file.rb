# frozen_string_literal: true

control "static_file" do
  variables = ::File.expand_path ::File.join("..", "..", "..", "..", "terraform", "Plug Ins"), __FILE__

  describe file ::File.join variables, "static_file.txt" do
    its("content") { should eq "abc" }
  end
end
