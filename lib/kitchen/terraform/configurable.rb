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

require "kitchen"
require "kitchen/terraform"
require "kitchen/terraform/version"

# Refinements to Kitchen::Configurable.
#
# @see https://github.com/test-kitchen/test-kitchen/blob/v1.16.0/lib/kitchen/configurable.rb Kitchen::Configurable
module ::Kitchen::Terraform::Configurable
  # A callback to define the plugin version which is invoked when this module is included in a plugin class.
  #
  # @return [self]
  def self.included(configurable_class)
    ::Kitchen::Terraform::Version.assign_plugin_version configurable_class: configurable_class
    self
  end

  private

  def expand_paths!
    validate_config! if !@validate_config_called
    super
  end

  def validate_config!
    @validate_config_called ||= true
    super
  end
end
