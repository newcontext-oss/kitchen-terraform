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

require "rubygems"

control "precedence" do
  title "precedence"
  desc "Tests to validate the precedence of overriding system attributes."

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

    if ::Gem::Requirement.new("~> 3.0").satisfied_by? ::Gem::Version.new ::Inspec::VERSION
      it "should eq \"From Attributes File\" in InSpec 3" do
        should eq "From Attributes File"
      end
    else
      it "should eq \"Second Output\" in InSpec 4" do
        should eq "Second Output"
      end
    end
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

    it { should eq "Third Output" }
  end

  describe "attribute(\"output_third_output\")" do
    subject do
      attribute("output_third_output")
    end

    it { should eq "First Output" }
  end

  describe "attribute(\"third_output\")" do
    subject do
      attribute("third_output")
    end

    it { should eq "Third Output" }
  end

  describe "attribute(\"undefined_output\")" do
    subject do
      attribute("undefined_output")
    end

    it { should eq "From Attributes File" }
  end

  describe "attribute(\"input_passthrough\")" do
    subject do
      attribute("input_passthrough")
    end

    it { should eq "value" }
  end
end
