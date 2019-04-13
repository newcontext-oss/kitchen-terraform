# frozen_string_literal: true

control "static_file" do
  describe file(::File.join(attribute("output_root_module_directory"), "static_file.txt")) do
    its("content") { should eq "abc" }
  end
end
