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

require "rubygems"
require "kitchen/terraform"

# This class represents the version of the Kitchen-Terraform gem.
module ::Kitchen::Terraform::Version
  self::VALUE = "3.3.1"

  def self.assign_specification_version(specification:)
    specification.version = value.to_s
    self
  end

  def self.assign_plugin_version(configurable_class:)
    configurable_class.plugin_version value.to_s
    self
  end

  def self.if_satisfies(requirement:)
    ::Gem::Requirement
      .new(requirement)
      .satisfied_by? value and
      yield

    self
  end

  def self.temporarily_override(version:)
    current_value = self.value
    self.value = version
    yield
    self.value = current_value
  end

  private_class_method

  def self.value
    self.value = self::VALUE if not @value
    @value
  end

  def self.value=(version)
    @value = ::Gem::Version.new version
    self
  end
end
