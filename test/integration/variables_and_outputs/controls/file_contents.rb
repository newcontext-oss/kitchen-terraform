# frozen_string_literal: true

local_file_content_from_configuration_variable = attribute "local_file_content_from_configuration_variable", {}
local_file_content_from_variable_file = attribute "local_file_content_from_variable_file", {}

control "file_contents" do
  variables_and_outputs = ::File.expand_path ::File.join("..", "..", "..", "..", "terraform", "variables_and_outputs"),
                                             __FILE__
  describe file ::File.join variables_and_outputs, "configuration_variable.txt" do
    its("content") { should eq local_file_content_from_configuration_variable }
  end

  describe file ::File.join variables_and_outputs, "variable_file.txt" do
    its("content") { should eq local_file_content_from_variable_file }
  end
end
