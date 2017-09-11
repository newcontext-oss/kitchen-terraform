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

# The +:variable_files+ configuration attribute is an optional array of string which represent file paths.
#
# @abstract It must be included by a plugin class in order to be used.
# @see https://www.terraform.io/docs/commands/apply.html#var-file-foo Terraform: Command: apply: -var-file
module ::Kitchen::Terraform::ConfigAttribute::VariableFiles
  # @return [::Array] an empty array.
  def self.default_value(**_keyword_arguments)
    []
  end

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
end
