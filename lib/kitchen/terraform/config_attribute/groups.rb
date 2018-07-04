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
# Many of these attributes map directly to {https://www.inspec.io/docs/reference/cli/#exec InSpec exec options}.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760193 Sequence of mappings}
# Required:: False
#
# ===== name
#
# This attribute contains the name of the group to be used for logging purposes.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: True
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#
# ===== attributes
#
# This attribute comprises associations of the names of
# {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes} with the names of
# {https://www.terraform.io/docs/configuration/outputs.html Terraform outputs}. The values of the outputs will be
# exposed as attributes when InSpec executes.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760142 Mapping of scalars to scalars}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           attributes:
#             an_attribute: an_output
# Caveat:: As all Terraform outputs are associated with equivalently named InSpec profile attributes by default, this
#          attribute is only necessary to provide alternative attribute names.
#
# ===== attrs
#
# This attribute comprises the paths to
# {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes} files.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           attrs:
#             - /path/to/first_attributes.yml
#             - /path/to/second_attributes.yml
#
# ===== backend
#
# This attribute contains the type of {https://www.inspec.io/docs/reference/cli/#exec InSpec backend} to be used for
# making a connection to hosts.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: True
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: docker
#
# ===== backend_cache
#
# This attribute toggles caching of InSpec backend command output.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend_cache: false
#
# ===== controls
#
# This attribute comprises the names of {https://www.inspec.io/docs/reference/dsl_inspec/ InSpec controls} to exclusively
# include from the InSpec profile of the associated Test Kitchen instance.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: first_group
#           controls:
#             - control_one
#             - control_three
#         - name: second_group
#           controls:
#             - control_two
#             - control_four
#
# ===== enable_password
#
# This attribute contains the password to use for authentication with a Cisco IOS device in enable mode.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: ssh
#           enable_password: Cisc0!
# Caveat:: InSpec will only use this attribute if it is configured in combination with the +backend: ssh+.
#
# ===== hosts_output
#
# This attribute contains the name of a Terraform output which provides one or more hosts to be targeted by the InSpec profile
# of the associated Test Kitchen instance.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           hosts_output: an_output
# Caveat:: The output must be a string or an array of strings.
#
# ===== key_files
#
# This attribute comprises paths to key files (also known as identity files) to be used for
# {https://linux.die.net/man/1/ssh SSH authentication} with hosts in the Terraform state.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: ssh
#           key_files:
#             - /path/to/first/key/file
#             - /path/to/second/key/file
# Caveat:: InSpec will only use this attribute if it is configured in combination with the +backend: ssh+.
#
# ===== password
#
# This attribute contains the password to use for authentication with hosts in the Terraform state.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: ssh
#           password: Th3P455I5Th3W0rd
#
# Caveat:: InSpec will only use this attribute if it is configured in combination with a backend which supports password
#          authentication.
#
# ===== path
#
# This attribute contains the login path to use when connecting to a target.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: winrm
#           path: /login
# Caveat:: InSpec will only use this attribute if it is configured in combination with the +backend: winrm+.
#
# ===== port
#
# This attribute contains the port to use when connecting with {https://en.wikipedia.org/wiki/Secure_Shell Secure Shell (SSH)}
# to the hosts of the group.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803828 Integer}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           port: 1234
# Caveat:: If this attribute is omitted then the port of the Test Kitchen SSH transport will be used.
#
# ===== proxy_command
#
# This attribute contains the proxy command to use when connecting to a target via SSH.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: ssh
#           proxy_command: ssh root@127.0.0.1 -W %h:%p
# Caveat:: InSpec will only use this attribute if it is configured in combination with the +backend: ssh+.
#
# ===== reporter
#
# This attribute comprises the {https://www.inspec.io/docs/reference/reporters/#supported-reporters InSpec reporters}
# to use when reporting test output.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760118 Sequence of scalars}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           reporter:
#             - cli
#             - documentation
#
# ===== self_signed
#
# This attribute toggles permission to use self-signed certificates while scanning remote Windows hosts.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           backend: winrm
#           self_signed: true
# Caveat:: InSpec will only use this attribute if it is configured in combination with the +backend: winrm+.
#
# ===== shell
#
# This attribute toggles the use of a subshell when scanning hosts.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2803629 Boolean}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           shell: true
# Caveat:: InSpec will only use this attribute if the system executing InSpec is Unix-like.
#
# ===== shell_command
#
# This attribute contains the shell command to use when connecting to a target.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           shell: true
#           shell_command: /bin/ksh
# Caveat:: InSpec will only use this attribute if it is configured in combination with +shell: true+.
#
# ===== shell_options
#
# This attribute contains the shell options to use when connecting to a target.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           shell: true
#           shell_options: -v
# Caveat:: InSpec will only use this attribute if it is configured in combination with +shell: true+.
#
# ===== user
#
# This attribute contains the name of the user to use for authentication with hosts in the Terraform state.
#
# Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
# Required:: False
# Example::
#   *kitchen.yml*
#     verifier:
#       name: terraform
#       groups:
#         - name: a_group
#           user: tester
# Caveat:: InSpec will only use this attribute if it is configured in combination with a backend which supports user
#          authentication.
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
