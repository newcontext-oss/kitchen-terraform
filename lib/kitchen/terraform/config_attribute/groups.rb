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
require "kitchen/terraform/config_attribute_definer"
require "kitchen/terraform/config_schemas/groups"

# The +:groups+ configuration attribute is an optional array including hashes comprising properties to manage the
# execution of InSpec profiles against different resources in the Terraform state.
#
# === Hash Keys
#
# ==== name
#
# A required string which contains the name of the group.
#
# ==== attributes
#
# An optional hash of symbols and strings which associates the names of InSpec profile attributes to the names of
# Terraform outputs.
#
# The attributes will be associated with the values of the outputs when InSpec runs.
#
# ==== controls
#
# An optional array of strings which contain the names of controls to exclusively include from the InSpec profile of the
# Test Kitchen suite.
#
# ==== hostnames
#
# An optional string which contains the name of a Terraform output.
#
# The output must be of type String or Array and must contain one or more hostnames that will be the targets of the
# InSpec profile of the Test Kitchen suite.
#
# If this key is omitted then localhost will be the target of the profile.
#
# ==== port
#
# An optional integer which represents the port to use when connecting to the hosts of the group with Secure Shell
# (SSH).
#
# If this key is omitted then the port of the Test Kitchen SSH Transport will be used.
#
# ==== ssh_key
#
# An optional string which contains the path to the private SSH key to use when connecting with SSH to the hosts of the
# group.
#
# If this key is omitted then the private SSH key of the Test Kitchen SSH Transport will be used.
#
# ==== username
#
# An optional string which contains the username to use when connecting to the hosts of the group with SSH.
#
# If this key is omitted then the username of the Test Kitcen SSH Transport will be used.
#
# @abstract It must be included by a plugin class in order to be used.
# @see https://github.com/test-kitchen/test-kitchen/blob/master/lib/kitchen/transport/ssh.rb Test Kitchen: SSH Transport
# @see https://www.inspec.io/docs/reference/dsl_inspec/ InSpec: Controls
# @see https://www.inspec.io/docs/reference/profiles/ InSpec: Profiles
# @see https://www.terraform.io/docs/configuration/outputs.html Terraform: Output Variables
# @see https://www.terraform.io/docs/state/index.html Terraform: State
module ::Kitchen::Terraform::ConfigAttribute::Groups
  # A callback to define the configuration attribute which is invoked when this module is included in a plugin class.
  #
  # @param plugin_class [::Kitchen::Configurable] A plugin class.
  # @return [void]
  def self.included(plugin_class)
    ::Kitchen::Terraform::ConfigAttributeDefiner
      .new(
        attribute: self,
        schema: ::Kitchen::Terraform::ConfigSchemas::Groups
      )
      .define plugin_class: plugin_class
  end

  # @return [::Symbol] the symbol corresponding to the attribute.
  def self.to_sym
    :groups
  end

  extend ::Kitchen::Terraform::ConfigAttributeCacher

  # @return [::Array] an empty array.
  def config_groups_default_value
    []
  end
end
