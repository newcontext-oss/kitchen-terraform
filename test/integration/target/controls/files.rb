# frozen_string_literal: true

control "variable_files" do
  describe file(::File.join(attribute("output_root_module_directory"), "file_1")) do
    its("content") { should eq "test" }
  end

  describe file(::File.join(attribute("output_root_module_directory"), "file_2")) do
    it { should_not exist }
  end
end
