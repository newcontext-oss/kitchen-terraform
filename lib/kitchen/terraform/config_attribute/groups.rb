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
#       - name: a_group
#         backend: local
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
#         backend: local
# Caveat:: As all Terraform outputs are associated with equivalently named InSpec profile attributes by default, this
#          key is only necessary to provide alternative attribute names.
#
# ===== attrs
#
# This key comprises the paths to
# {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes} files.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_profile_attributes
#         attrs:
#           - /path/to/first_attributes.yml
#           - /path/to/second_attributes.yml
#         backend: local
#
# ===== backend
#
# This key contains the type of {https://www.inspec.io/docs/reference/cli/#exec InSpec backend} to be used for making a
# connection to hosts.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: True
# Example::
#   _
#     groups:
#       - name: a_group_with_a_backend
#         backend: docker
#
# ===== backend_cache
#
# This key toggles caching of InSpec backend command output.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
# Required:: False
# Default:: +true+
# Example::
#   _
#     groups:
#       - name: a_group_with_no_backend_cache
#         backend: local
#         backend_cache: false
#
# ===== controls
#
# This key comprises the names of {https://www.inspec.io/docs/reference/dsl_inspec/ InSpec controls} to exclusively
# include from the InSpec profile of the associated Test Kitchen instance.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
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
# ===== enable_password
#
# This key contains the password to use for authentication with a Cisco IOS device in enable mode.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_enable_password
#         backend: ssh
#         enable_password: Cisc0!
# Caveat:: InSpec will only use this key if it is configured in combination with the +ssh+ backend.
#
# ===== hosts_output
#
# This key contains the name of a Terraform output which provides one or more hosts to be targeted by the InSpec profile
# of the associated Test Kitchen instance.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_hosts
#         backend: ssh
#         hosts_output: an_output
# Caveat:: The output must be a string or an array of strings. To connect to the hosts through a bastion host, a
#          +ProxyCommand+ in the appropriate {https://linux.die.net/man/5/ssh_config SSH configuration file} must be
#          configured on the system.
#
# ===== key_files
#
# This key comprises paths to key files (also known as identity files) to be used for
# {https://linux.die.net/man/1/ssh SSH authentication} with hosts in the Terraform state.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
# Required:: False
# Example::
#   _
#     groups:
#       -
#         name: a_group_with_key_files
#         backend: ssh
#         hosts_output: an_output
#         key_files:
#           - /path/to/first/key/file
#           - /path/to/second/key/file
# Caveat:: InSpec will only use this key if it is configured in combination with the +ssh+ backend.
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
module ::Kitchen::Terraform::ConfigAttribute::Groups
  ::Kitchen::Terraform::ConfigAttribute
    .new(
      attribute: :groups,
      default_value:
        lambda do
          []
        end,
      schema: ::Kitchen::Terraform::ConfigSchemas::Groups
    )
    .apply config_attribute: self
end
