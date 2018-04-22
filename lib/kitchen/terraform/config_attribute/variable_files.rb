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

require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_schemas/array_of_strings"
require "kitchen/terraform/file_path_config_attribute_definer"

# This attribute comprises paths to
# {https://www.terraform.io/docs/configuration/variables.html#variable-files Terraform variable files}.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequince of scalars}
# Required:: False
# Example::
#   _
#     variable_files:
#       - /path/to/first/variable/file
#       - /path/to/second/variable/file
#
# @abstract It must be included by a plugin class in order to be used.
module ::Kitchen::Terraform::ConfigAttribute::VariableFiles
  # A callback to define the configuration attribute which is invoked when this module is included in a plugin class.
  #
  # @param plugin_class [::Kitchen::Configurable] A plugin class.
  # @return [void]
  def self.included(plugin_class)
    ::Kitchen::Terraform::FilePathConfigAttributeDefiner
      .new(
        attribute: self,
        schema: ::Kitchen::Terraform::ConfigSchemas::ArrayOfStrings
      )
      .define plugin_class: plugin_class
  end

  # @return [::Symbol] the symbol corresponding to this attribute.
  def self.to_sym
    :variable_files
  end

  extend ::Kitchen::Terraform::ConfigAttributeCacher

  # @return [::Array] an empty array.
  def config_variable_files_default_value
    []
  end
end
