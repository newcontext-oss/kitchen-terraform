# frozen_string_literal: true

control "variables" do
  describe file(::File.join(attribute("output_root_module_directory"), "string.txt")) do
    its("content") { should eq "A String" }
  end

  describe file(::File.join(attribute("output_root_module_directory"), "map.txt")) do
    its("content") { should eq "A Value" }
  end

  describe file(::File.join(attribute("output_root_module_directory"), "list.txt")) do
    its("content") { should eq "Element One; Element Two" }
  end
end
