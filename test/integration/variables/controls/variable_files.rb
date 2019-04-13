# frozen_string_literal: true

control "variable_files" do
  describe file(::File.join(attribute("output_root_module_directory"), "variable_file.txt")) do
    its("content") { should eq "123" }
  end
end
