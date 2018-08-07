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

require "dry/validation"
require "kitchen/terraform/config_schemas"

module Kitchen
  module Terraform
    module ConfigSchemas
      # A system is a mapping which is used to configure the execution of {https://www.inspec.io/docs/ InSpec tests}
      # against a system in the Terraform state.
      #
      # All systems within the same {https://kitchen.ci/docs/getting-started/adding-suite Kitchen suite} are tested
      # using the same {https://www.inspec.io/docs/reference/profiles/ InSpec profile}. The profile must be implemented
      # in the directory located at `<Kitchen root>/test/integration/<suite name>`.
      #
      # The values of all {https://www.terraform.io/docs/configuration/outputs.html Terraform outputs} are associated
      # with equivalently named
      # {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes}.
      #
      # The keys of a system mapping correlate to the options of the
      # {https://www.inspec.io/docs/reference/cli/#exec +inspec exec+} command-line interface subcomamand.
      #
      # ===== Required Keys
      #
      # ====== name
      #
      # The value of the +name+ key is a scalar which is used to refer to the system for logging purposes.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #
      # ====== backend
      #
      # The value of the +backend+ key is a scalar which is used to select the
      # {https://www.inspec.io/docs/reference/cli/#exec InSpec backend} for connections to the system.
      #
      # The scalar must match the name of one the available backends.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: docker
      #
      # ===== Optional Keys
      #
      # ====== attrs
      #
      # The value of the +attrs+ key is a sequence of scalars which is used to locate any
      # {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes} files.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #         attrs:
      #           - /path/to/first_attributes.yml
      #           - /path/to/second_attributes.yml
      #
      # ====== attrs_outputs
      #
      # The value of the +attrs_outputs+ key is a mapping of scalars to scalars which is used to define
      # {https://www.inspec.io/docs/reference/profiles/#profile-attributes InSpec profile attributes} with the values
      # of Terraform outputs.
      #
      # The use of the +attrs_outputs+ key is only necessary to override the default definitions of profile attributes
      # with names and values equivalent to the outputs.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #         attrs_outputs:
      #           an_attribute_name: an_output_name
      #
      # ====== backend_cache
      #
      # The value of the +backend_cache+ key is a boolean which is used to toggle the caching of InSpec backend command
      # output.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #         backend_cache: false
      #
      # ====== bastion_host
      #
      # The value of the +bastion_host+ key is a scalar which is used as the hostname of a
      # {https://en.wikipedia.org/wiki/Bastion_host bastion host} to connect to before connecting to hosts in the
      # system.
      #
      # The +bastion_host+ key must be used in combination with a backend which supports remote connections.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         bastion_host: bastion-host.domain
      #
      # ====== bastion_port
      #
      # The value of the +bastion_port+ key is an integer which is used as the port number to connect to on the bastion
      # host.
      #
      # The +bastion_port+ key must be used in combination with the +bastion_host+ key.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         bastion_host: bastion-host.domain
      #         bastion_port: 1234
      #
      # ====== bastion_user
      #
      # The value of the +bastion_user+ key is a scalar which is used as the username for authentication with the
      # bastion host.
      #
      # The +bastion_user+ key must be used in combination with the +bastion_host+ key.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         bastion_host: bastion-host.domain
      #         bastion_user: bastion-user
      #
      # ====== controls
      #
      # The value of the +controls+ key is a sequence of scalars which is used to select for execution against the
      # system a subset of the {https://www.inspec.io/docs/reference/dsl_inspec/ InSpec controls} of the profile.
      #
      # The use of the +controls+ key is only necessary if the system should not be tested with all of the controls of # the profile.
      #
      # The scalars must match the names of the controls, not the names of the control files.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: first system
      #         backend: local
      #         controls:
      #           - first control
      #           - third control
      #       - name: second system
      #         backend: local
      #         controls:
      #           - second control
      #           - fourth control
      #
      # ====== enable_password
      #
      # The value of the +enable_password+ key is a scalar which is used as the password for authentication with a
      # Cisco IOS device in enable mode.
      #
      # The +enable_password+ key must be used in combination with +backend: ssh+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         enable_password: Cisc0!
      #
      # ====== hosts_output
      #
      # The value of the +hosts_output+ key is a scalar which is used to obtain the addresses of hosts in the system
      # from a Terraform output.
      #
      # The scalar must match the name of an output with a value which is a string or an array of strings.
      #
      # The +hosts_output+ key must be used in combination with a backend which enables remote connections.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #
      # ====== key_files
      #
      # The value of the +key_files+ key is a sequence of scalars which is used to locate key files (also known as
      # identity files) for {https://linux.die.net/man/1/ssh Secure Shell (SSH) authentication} with hosts in the
      # Terraform state.
      #
      # The +key_files+ key must be used in combination with +backend: ssh+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         key_files:
      #           - /path/to/first/key/file
      #           - /path/to/second/key/file
      #
      # ====== password
      #
      # The value of the +password+ key is a scalar which is used as the password for authentication with hosts in the
      # system.
      #
      # The +password+ key must be used in combination with a backend which supports password authentication.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         password: Th3P455I5Th3W0rd
      #
      # ====== path
      #
      # The value of the +path+ key is a scalar which is used as the login path when connecting to a host in the system.
      #
      # The +path+ key must be used in combination with +backend: winrm+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: winrm
      #         path: /login
      #
      # ====== port
      #
      # The value of the +port+ key is an integer which is used as the port number when connecting via SSH to the hosts
      # of the system.
      #
      # The +port+ key must be used in combination with +backend: ssh+.
      #
      # If the +port+ key is omitted then the value of the +port+ key of the Test Kitchen transport will be used.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         port: 1234
      #
      # ====== proxy_command
      #
      # The value of the +proxy_command+ key is a scalar which is used as a proxy command when connecting to a host via
      # SSH.
      #
      # The +proxy_command+ key must be used in combination with +backend: ssh+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         proxy_command: ssh root@127.0.0.1 -W %h:%p
      #
      # ====== reporter
      #
      # The value of the +reporter+ key is a sequence of scalars which is used to select the
      # {https://www.inspec.io/docs/reference/reporters/#supported-reporters InSpec reporters}
      # for reporting test output.
      #
      # The scalars must match the names of the available reporters.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #         reporter:
      #           - cli
      #           - documentation
      #
      # ====== self_signed
      #
      # The value of the +self_signed+ key is a boolean which is used to toggle permission for self-signed certificates
      # during testing of Windows hosts.
      #
      # The +self_signed+ key must be used in combination with +backend: winrm+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: winrm
      #         self_signed: true
      #
      # ====== shell
      #
      # The value of the +shell+ key is a boolean which is used to toggle the use of a subshell when executing tests on
      # hosts in the system.
      #
      # The +shell+ key is only effective for a system which has Unix-like hosts.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         shell: true
      #
      # ====== shell_command
      #
      # The value of the +shell_command+ key is a scalar which is used to override the default shell command used to
      # instantiate a subshell.
      #
      # The +shell_command+ key must be used in combination with +shell: true+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         shell: true
      #         shell_command: /bin/ksh
      #
      # ====== shell_options
      #
      # The value of the +shell_options+ key is a scalar which is used to provide options to the subshell.
      #
      # The +shell_options+ key must be used in combination with +shell: true+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         shell: true
      #         shell_options: -v
      #
      # ====== show_progress
      #
      # The value of the +show_progress+ key is a boolean which is used to toggle the display of progress while tests
      # are executing.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #         show_progress: false
      #
      # ====== ssl
      #
      # The value of the +ssl+ key is a boolean which is used to toggle the use of
      # {https://en.wikipedia.org/wiki/Transport_Layer_Security Transport Layer Security (TLS)} when connecting to
      # hosts in the system. InSpec's reference to Secure Socket Layer (SSL) is a misnomer as that protocol has been
      # deprecated in favour of TLS.
      #
      # The +ssl+ key must be used in combination with +backend: winrm+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: winrm
      #         ssl: true
      #
      # ====== sudo
      #
      # The value of the +sudo+ key is a boolean which is used to toggle the use of
      # {https://en.wikipedia.org/wiki/Sudo sudo} for obtaining superuser permissions when executing tests on hosts in
      # the system.
      #
      # The +sudo+ key is only effective for a system which has Unix-like hosts.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         sudo: true
      #
      # ====== sudo_command
      #
      # The value of the +sudo_command+ key is a scalar which is used to override the default command used to
      # invoke sudo.
      #
      # The +sudo_command+ key must be used in combination with +sudo: true+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         sudo: true
      #         sudo_command: /bin/sudo
      #
      # ====== sudo_options
      #
      # The value of the +sudo_options+ key is a scalar which is used to provide options to the sudo command.
      #
      # The +sudo_options+ key must be used in combination with +sudo: true+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         sudo: true
      #         sudo_options: -u admin
      #
      # ====== sudo_password
      #
      # The value of the +sudo_password+ key is a scalar which is used as the password for authentication with the sudo
      # command.
      #
      # The +sudo_password+ key must be used in combination with +sudo: true+.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         hosts_output: an_output
      #         sudo: true
      #         sudo_password: Th3P455I5Th3W0rd
      #
      # ====== user
      #
      # The value of the +user+ key is a scalar which is used as the username for authentication with hosts in the
      # system.
      #
      # The +user+ key must be used in combination with a backend which supports user authentication.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: ssh
      #         user: tester
      #
      # ====== vendor_cache
      #
      # The value of the +vendor_cache+ key is a scalar which is used as the pathname of the directory in which InSpec
      # will cache dependencies of the profile.
      #
      # <em>Example kitchen.yml</em>
      #   verifier:
      #     name: terraform
      #     systems:
      #       - name: a system
      #         backend: local
      #         vendor_cache: /opt/inspec-cache
      System = ::Dry::Validation.Params do
        required(:name).filled :str?
        required(:backend).filled :str?
        optional(:attributes).filled :hash?
        optional(:attrs).each(:filled?, :str?)
        optional(:backend_cache).value :bool?
        optional(:bastion_host).filled :str?
        optional(:bastion_port).value :int?
        optional(:bastion_user).filled :str?
        optional(:controls).each(:filled?, :str?)
        optional(:enable_password).filled :str?
        optional(:hosts_output).filled :str?
        optional(:key_files).each(:filled?, :str?)
        optional(:password).filled :str?
        optional(:path).filled :str?
        optional(:port).value :int?
        optional(:proxy_command).filled :str?
        optional(:reporter).each(:filled?, :str?)
        optional(:self_signed).value :bool?
        optional(:shell).value :bool?
        optional(:shell_command).filled :str?
        optional(:shell_options).filled :str?
        optional(:show_progress).value :bool?
        optional(:ssl).value :bool?
        optional(:sudo).value :bool?
        optional(:sudo_command).filled :str?
        optional(:sudo_options).filled :str?
        optional(:sudo_password).filled :str?
        optional(:user).filled :str?
        optional(:vendor_cache).filled :str?
      end
    end
  end
end
