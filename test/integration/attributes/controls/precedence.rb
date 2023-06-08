# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

  describe "attribute(\"output_insensitive_string\")" do
    subject do
      attribute("output_insensitive_string")
    end

    it { should eq "insensitive-value" }
  end

  describe "attribute(\"insensitive_string\")" do
    subject do
      attribute("insensitive_string")
    end

    if ::Gem::Requirement.new("~> 3.0").satisfied_by? ::Gem::Version.new ::Inspec::VERSION
      it "should eq \"From Attributes File\" in InSpec 3" do
        should eq "From Attributes File"
      end
    else
      it "should eq \"value\" in InSpec 4" do
        should eq "sensitive-value"
      end
    end
  end

  describe "attribute(\"output_sensitive_string\")" do
    subject do
      attribute("output_sensitive_string")
    end

    it { should eq "insensitive-value" }
  end

  describe "attribute(\"sensitive_string\")" do
    subject do
      attribute("sensitive_string")
    end

    it { should eq "sensitive-value" }
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
