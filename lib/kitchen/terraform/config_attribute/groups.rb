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

# This attribute configures the execution of {https://www.inspec.io/docs/reference/profiles/ InSpec profiles} against
# different groups of resources in the Terraform state. Each group may be configured by using the proceeding attributes.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760193 Sequence of mappings}
# Required:: False
#
# ===== name
#
# This key contains the name of the group to be used for logging purposes.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: True
# Example::
#   _
#     groups:
#       -
#         name: a_group
#
# ===== attributes
#
# This key comprises associations of the names of
# {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes} with the names of
# {https://www.terraform.io/docs/configuration/outputs.html Terraform outputs}. The values of the outputs will be
# exposed as attributes when InSpec executes.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760142 Mapping of scalars to scalars}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_overridden_attributes
#         attributes:
#           an_attribute: an_output
# Caveat:: As all Terraform outputs are associated with equivalently named InSpec profile attributes by default, this
#          key is only necessary to provide alternative attribute names.
#
# ===== controls
#
# This key comprises the names of {https://www.inspec.io/docs/reference/dsl_inspec/ InSpec controls} to exclusively
# include from the InSpec profile of the associated Test Kitchen instance.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequince of scalars}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_a_first_subset_of_controls
#         controls:
#           - control_one
#           - control_three
#       -
#         name: a_group_with_a_second_subset_of_controls
#         controls:
#           - control_two
#           - control_four
#
# ===== fail_fast
#
# This key toggles between immediate failure and delayed failure when the group is determined to be noncompliant with
# the associated InSpec profile.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
# Required:: False
# Default:: +true+
# Example::
#   _
#     groups:
#       -
#         name: a_group_which_fails_slowly
#         fail_fast: false
#
# ==== hostnames
#
# This key contains the name of a Terraform output which provides one or more hostnames to be targeted by the InSpec
# profile of the associated Test Kitchen instance.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_hostnames
#         hostnames: an_output
# Caveat:: The output must be of type String or Array and . If this key is omitted then +"localhost"+ will be the target
#          of the profile.
#
# ===== port
#
# This key contains the port to use when connecting with {https://en.wikipedia.org/wiki/Secure_Shell Secure Shell (SSH)}
# to the hosts of the group.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803828 Integer}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_a_port
#         port: 1234
# Caveat:: If this key is omitted then the port of the Test Kitchen SSH transport will be used.
#
# ===== ssh_key
#
# This key contains the path to a private SSH key to use when connecting with SSH to the hosts of the group.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_an_ssh_key
#         ssh_key: /path/to/an/ssh/key</
# Caveat:: If this key is omitted then the private SSH key of the Test Kitchen SSH Transport will be used.
#
# ===== username
#
# This key contains the username to use when connecting with SSH to the hosts of the group.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_a_username
#         username: tester
# Caveat:: If this key is omitted then the username of the Test Kitcen SSH Transport will be used.
#
# @abstract It must be included by a plugin class in order to be used.
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
