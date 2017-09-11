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

require "kitchen/terraform"

# Behaviour to cache configuration attribute lookups.
module ::Kitchen::Terraform::ConfigAttributeCacher
  # A callback to define an attribute lookup cache which is invoked when this module is extended by a
  # configuration attribute.
  #
  # @param configuration_attribute [::Kitchen::Terraform::ConfigAttribute] a configuration attribute.
  def self.extended(configuration_attribute)
    configuration_attribute.define_cache
  end

  # Defines an instance method named "config_<attribute_name>" which caches the value of the configuration attribute
  # lookup using an equivalently named instance variable.
  #
  # @param attribute_name [::Symbol] the name of the attribute
  def define_cache(attribute_name: to_sym)
    define_method "config_#{attribute_name}" do
      instance_variable_defined? "@config_#{attribute_name}" and
        instance_variable_get "@config_#{attribute_name}" or
        instance_variable_set(
          "@config_#{attribute_name}",
          config.fetch(attribute_name)
        )
    end
  end
end
