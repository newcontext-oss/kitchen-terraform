# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

control "variables" do
  describe "string.txt" do
    subject do
      file(::File.join(attribute("output_root_module_directory"), "string.txt"))
    end

    its("content") { should eq "A String" }
  end

  describe "map.txt" do
    subject do
      file(::File.join(attribute("output_root_module_directory"), "map.txt"))
    end

    its("content") { should eq "A Value" }
  end

  describe "list_of_strings.txt" do
    subject do
      file(::File.join(attribute("output_root_module_directory"), "list_of_strings.txt"))
    end

    its("content") { should eq "Element One; Element Two" }
  end

  describe "list_of_maps.txt" do
    subject do
      file(::File.join(attribute("output_root_module_directory"), "list_of_maps.txt"))
    end

    its("content") { should eq "A List Of Maps Value" }
  end
end
