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
require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_attribute_definer"
require "kitchen/terraform/config_schemas/boolean"

# This attribute toggles colored output from systems invoked by the plugin.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
# Required:: False
# Default:: If a {https://en.wikipedia.org/wiki/Terminal_emulator terminal emulator} is associated with the Test Kitchen
#           process then +true+; else +false+.
# Example:: <code>color: false</code>
# Caveat:: This attribute does not toggle colored output from the Test Kitchen core, though it does use the same default
#          logic. To toggle colored output from the core, the +--color+ and +--no-color+ command-line flags must be
#          used.
#
# @abstract It must be included by plugin class in order to be used.
module ::Kitchen::Terraform::ConfigAttribute::Color
  # A callback to define the configuration attribute which is invoked when this module is included in a plugin class.
  #
  # @param plugin_class [::Kitchen::Configurable] A plugin class.
  # @return [void]
  def self.included(plugin_class)
    ::Kitchen::Terraform::ConfigAttributeDefiner
      .new(
        attribute: self,
        schema: ::Kitchen::Terraform::ConfigSchemas::Boolean
      )
      .define plugin_class: plugin_class
  end

  # @return [::Symbol] the symbol corresponding to the attribute.
  def self.to_sym
    :color
  end

  extend ::Kitchen::Terraform::ConfigAttributeCacher

  # The default value depends on the presence of a terminal device associated with the Test Kitchen process.
  #
  # @return [Boolean] if a terminal device is associated then +true+; else +false+.
  def config_color_default_value
    ::Kitchen.tty?
  end

  # @return [::String] the toggle converted to a flag.
  def config_color_flag
    config_color and "" or "-no-color"
  end
end
