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

require "kitchen"
require "kitchen/terraform/version"
require "rubygems"

::RSpec.describe ::Kitchen::Terraform::Version do
  subject do
    described_class
  end

  let :version do
    ::Gem::Version.new "7.0.1"
  end

  describe ".assign_plugin_version" do
    let :configurable_class do
      ::Class.new do
        class << self
          def read_plugin_version
            @plugin_version
          end
        end

        include ::Kitchen::Configurable
      end
    end

    specify "should assign the version to the plugin" do
      expect do
        subject.assign_plugin_version configurable_class: configurable_class
      end.to change(configurable_class, :read_plugin_version).to version.to_s
    end
  end

  describe ".assign_specification_version" do
    let :specification do
      ::Gem::Specification.new
    end

    specify "should assign the version to the specification" do
      expect do
        subject.assign_specification_version specification: specification
      end.to change(specification, :version).from(nil).to version
    end
  end

  describe ".if_satisfies" do
    context "when the requirement is satisfied by the version" do
      specify do
        expect do |block|
          subject.if_satisfies requirement: ::Gem::Requirement.new(">= 0"), &block
        end.to yield_control
      end
    end

    context "when the requirement is not satisfied by the version" do
      specify do
        expect do |block|
          subject.if_satisfies requirement: "~> 0.0.1", &block
        end.not_to yield_control
      end
    end
  end

  describe ".temporarily_override" do
    specify "should override the current version with the provided version before control is yielded" do
      expect do |block|
        subject.temporarily_override version: "0.0.0" do
          subject.if_satisfies requirement: "< 1.0.0", &block
        end
      end.to yield_control
    end

    specify "should reset the version after control is returned" do
      expect do |block|
        subject.temporarily_override version: "0.0.0" do
        end

        subject.if_satisfies requirement: version, &block
      end.to yield_control
    end
  end
end
