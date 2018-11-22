# frozen_string_literal: true

control "variable_files" do
  variables = ::File.expand_path ::File.join("..", "..", "..", "..", "terraform", "variables"), __FILE__

  describe file ::File.join variables, "variable_file.txt" do
    its("content") { should eq "123" }
  end
end
