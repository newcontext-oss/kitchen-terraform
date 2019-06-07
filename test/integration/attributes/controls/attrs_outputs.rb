# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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

control "attrs_outputs" do
  title "attrs_outputs"
  desc "Tests to validate the behaviour of the attrs_outputs system key."

  describe "attribute(\"output_first_output\")" do
    subject do
      attribute("output_first_output")
    end

    it { should eq "First Output" }
  end

  describe "attribute(\"first_output\")" do
    subject do
      attribute("first_output")
    end

    it { should eq "Second Output" }
  end

  describe "attribute(\"output_second_output\")" do
    subject do
      attribute("output_second_output")
    end

    it { should eq "Second Output" }
  end

  describe "attribute(\"second_output\")" do
    subject do
      attribute("second_output")
    end

    it { should eq "Second Output" }
  end

  describe "attribute(\"output_third_output\")" do
    subject do
      attribute("output_third_output")
    end

    it { should eq "Third Output" }
  end

  describe "attribute(\"third_output\")" do
    subject do
      attribute("third_output")
    end

    it { should eq "Third Output" }
  end

  describe "attribute(\"input_passthrough\")" do
    subject do
      attribute("input_passthrough")
    end

    it { should eq "value" }
  end
end
