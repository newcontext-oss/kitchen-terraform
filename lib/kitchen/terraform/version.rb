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

# The version of the kitchen-terraform gem.
class ::Kitchen::Terraform::Version
  def assign_specification_version(specification:)
    specification.version = @version.to_s
    self
  end

  def assign_plugin_version(configurable_class:)
    configurable_class.plugin_version @version.to_s
    self
  end

  def if_satisfies(requirement:)
    yield if requirement.satisfied_by? @version
    self
  end

  private

  def initialize(version: "3.3.1")
    @version = ::Gem::Version.new version
  end
end
