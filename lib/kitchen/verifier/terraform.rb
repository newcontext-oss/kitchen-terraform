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
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/groups"
require "kitchen/terraform/configurable"
require "kitchen/terraform/error"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Verifier
module ::Kitchen::Verifier
end

# The verifier utilizes the {https://www.inspec.io/ InSpec infrastructure testing framework} to verify the behaviour and
# state of resources in the Terraform state.
#
# === Commands
#
# The following command-line commands are provided by the verifier.
#
# ==== kitchen verify
#
# A Test Kitchen instance is verified by iterating through the groups and executing the associated InSpec controls in a
# manner similar to the following command-line command.
#
#   inspec exec \
#     [--attrs=<terraform_outputs>] \
#     --backend=<ssh|local> \
#     [--no-color] \
#     [--controls=<group.controls>] \
#     --host=<group.hostnames.current|localhost> \
#     [--password=<group.password>] \
#     [--port=<group.port>] \
#     --profiles-path=test/integration/<suite> \
#     [--user=<group.username>] \
#
# === InSpec Profiles
#
# The {https://www.inspec.io/docs/reference/profiles/ InSpec profile} for a Test Kitchen suite must be defined under
# +./test/integration/<suite>/+.
#
# === Configuration Attributes
#
# The configuration attributes of the verifier control the behaviour of the InSpec runner. Within the
# {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}, these attributes must be
# declared in the +verifier+ mapping along with the plugin name.
#
#   verifier:
#     name: terraform
#     a_configuration_attribute: some value
#
# ==== color
#
# {include:Kitchen::Terraform::ConfigAttribute::Color}
#
# ==== groups
#
# {include:Kitchen::Terraform::ConfigAttribute::Groups}
#
# This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
# :reek:PrimaDonnaMethod { exclude: [ finalize_config!, load_needed_dependencies! ] }
class ::Kitchen::Verifier::Terraform
  include ::Kitchen::Configurable
  include ::Kitchen::Logging
  include ::Kitchen::Terraform::ConfigAttribute::Color
  include ::Kitchen::Terraform::ConfigAttribute::Groups
  include ::Kitchen::Terraform::Configurable
  @api_version = 2

  # The verifier enumerates through each hostname of each group and verifies the associated InSpec controls.
  #
  # @example
  #   `kitchen verify suite-name`
  # @param kitchen_state [::Hash] the mutable instance and verifier state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [void]
  def call(kitchen_state)
    load_output kitchen_state: kitchen_state

    ::Kitchen::Verifier::Terraform::EnumerateGroupsAndHostnames
      .call(
        groups: config_groups,
        output: output
      ) do |group:, hostname:|
        verify(
          group: group,
          hostname: hostname
        )
      end
  rescue ::Kitchen::Terraform::Error => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end

  # doctor checks the system and configuration for common errors.
  #
  # @param _kitchen_state [::Hash] the mutable Kitchen instance state.
  # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
  # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/verifier/base.rb#L85-L91
  def doctor(_kitchen_state)
    false
  end

  # finalize_config! configures InSpec options which remain consistent between groups.
  #
  # @param kitchen_instance [::Kitchen::Instance] an associated Kitchen instance.
  # @return [self]
  def finalize_config!(kitchen_instance)
    super kitchen_instance

    kitchen_instance
      .transport
      .tap do |transport|
        configure_inspec_connection_options(
          transport_connection_options:
            transport
            .send(
              :connection_options,
              transport.diagnose
            )
            .dup
        )
      end

    configure_inspec_miscellaneous_options
  end

  private

  attr_accessor :inspec_options
  attr_reader :output

  # @api private
  def configure_inspec_connection_options(transport_connection_options:)
    inspec_options
      .merge!(
        ::Kitchen::Util
          .stringified_hash(
            transport_connection_options
              .slice(
                :compression,
                :compression_level,
                :connection_retries,
                :connection_retry_sleep,
                :timeout,
                :keepalive,
                :keepalive_interval,
                :max_wait_until_ready
              )
          )
      )

    inspec_options
      .store(
        "connection_timeout",
        inspec_options.delete("timeout")
      )
  end

  # @api private
  def configure_inspec_group_connection_options(group:, hostname:)
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend
      .call(
        hostname: hostname,
        options: inspec_options
      )

    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost
      .call(
        hostname: hostname,
        options: inspec_options
      )

    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort
      .call(
        group: group,
        options: inspec_options
      )

    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerSSHKey
      .call(
        group: group,
        options: inspec_options
      )

    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser
      .call(
        group: group,
        options: inspec_options
      )
  end

  # @api private
  def configure_inspec_profile_options(group:)
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
      .call(
        group: group,
        options: inspec_options,
        output: output
      )

    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerControls
      .call(
        group: group,
        options: inspec_options
      )
  end

  # @api private
  def configure_inspec_miscellaneous_options
    inspec_options
      .merge!(
        "backend" => "ssh",
        "color" => config_color,
        "logger" => logger,
        "sudo" => false,
        "sudo_command" => "sudo -E",
        "sudo_options" => "",
        attrs: nil,
        backend_cache: false
      )
  end

  # @api private
  def load_output(kitchen_state:)
    @output = ::Kitchen::Util.stringified_hash Hash kitchen_state.fetch :kitchen_terraform_output
  rescue ::KeyError
    raise(
      ::Kitchen::Terraform::Error,
      "The Kitchen state does not include :kitchen_terraform_output; this implies that the kitchen-terraform " \
        "provisioner has not successfully converged"
    )
  end

  # @api private
  def initialize(configuration = {})
    init_config configuration
    self.inspec_options = {}
  end

  # load_needed_dependencies! loads the InSpec libraries required to verify a Terraform state.
  #
  # @api private
  # @raise [::Kitchen::ClientError] if loading the InSpec libraries fails.
  # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/configurable.rb#L252-L274
  def load_needed_dependencies!
    require "kitchen/terraform/inspec"
  rescue ::LoadError => load_error
    raise(
      ::Kitchen::ClientError,
      load_error.message
    )
  end

  # @api private
  # @raise [::Kitchen::Terraform::Error] if running InSpec results in failure.
  def verify(group:, hostname:)
    info "Verifying host '#{hostname}' of group '#{group.fetch :name}'"

    configure_inspec_group_connection_options(
      group: group,
      hostname: hostname
    )

    configure_inspec_profile_options group: group

    ::Kitchen::Terraform::InSpec
      .new(options: inspec_options)
      .run
  end
end

require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "kitchen/verifier/terraform/configure_inspec_runner_backend"
require "kitchen/verifier/terraform/configure_inspec_runner_controls"
require "kitchen/verifier/terraform/configure_inspec_runner_host"
require "kitchen/verifier/terraform/configure_inspec_runner_port"
require "kitchen/verifier/terraform/configure_inspec_runner_ssh_key"
require "kitchen/verifier/terraform/configure_inspec_runner_user"
require "kitchen/verifier/terraform/enumerate_groups_and_hostnames"
