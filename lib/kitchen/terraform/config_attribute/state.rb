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
require "kitchen/terraform/config_schemas/string"
require "kitchen/terraform/file_path_config_attribute_definer"

# The +:state+ configuration attribute is an optianl string which contains the path to the Terraform state file which
# will be generated and managed.
#
# @abstract It must be included by a plugin class in order to be used.
# @see https://www.terraform.io/docs/commands/apply.html#state-path Terraform: Command: apply: -state-path
# @see https://www.terraform.io/docs/state/index.html Terraform: State
module ::Kitchen::Terraform::ConfigAttribute::State
  # A callback to define the configuration attribute which is invoked when this module is included in a plugin class.
  #
  # @param plugin_class [::Kitchen::Configurable] A plugin class.
  # @return [void]
  def self.included(plugin_class)
    ::Kitchen::Terraform::FilePathConfigAttributeDefiner
      .new(
        attribute: self,
        schema: ::Kitchen::Terraform::ConfigSchemas::String
      )
      .define plugin_class: plugin_class
  end

  # @return [::Symbol] the symbol corresponding to this attribute.
  def self.to_sym
    :state
  end

  extend ::Kitchen::Terraform::ConfigAttributeCacher

  # The path to a file under the kitchen-terraform suite directory.
  #
  # @return [::String] +".kitchen/kitchen-terraform/<suite_name>/terraform.tfstate"+.
  def config_state_default_value
    instance_pathname filename: "terraform.tfstate"
  end
end
