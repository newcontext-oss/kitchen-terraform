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
# :reek:PrimaDonnaMethod { exclude: [ load_needed_dependencies! ] }
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
        kitchen_state
          .store(
            :kitchen_terraform_group,
            group
          )
        kitchen_state
          .store(
            :kitchen_terraform_hostname,
            hostname
          )
        info "Verifying host '#{hostname}' of group '#{group.fetch :name}'"
        ::Inspec::Runner
          .new(runner_options(kitchen_state: kitchen_state))
          .tap do |runner|
            valid_exit_codes =
              [
                0,
                101
              ]

            exit_code = runner.run

            if not valid_exit_codes.include? exit_code
              raise(
                ::Kitchen::Terraform::Error,
                "InSpec Runner exited with #{exit_code}"
              )
            end
          end
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
  # @returns [Boolean] +true+ if any errors are found; +false+ if no errors are found.
  # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/verifier/base.rb#L85-L91
  def doctor(_kitchen_state)
    false
  end

  private

  attr_reader :output

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
  end

  # load_needed_dependencies! loads the InSpec libraries required to verify a Terraform state.
  #
  # @api private
  # @raise [::Kitchen::ClientError] if loading the InSpec libraries fails.
  # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/configurable.rb#L252-L274
  def load_needed_dependencies!
    require "inspec"
    require "inspec/cli"
  rescue ::LoadError => load_error
    raise(
      ::Kitchen::ClientError,
      load_error.message
    )
  end

  # @api private
  def runner_options(kitchen_state:)
    transport_connection_options =
      instance
        .transport
        .send(
          :connection_options,
          instance
            .transport
            .diagnose
            .merge(kitchen_state)
        )
        .dup

    {
      "backend" => "ssh",
      "color" => config_color,
      "compression" => transport_connection_options.fetch(:compression),
      "compression_level" => transport_connection_options.fetch(:compression_level),
      "connection_retries" => transport_connection_options.fetch(:connection_retries),
      "connection_retry_sleep" => transport_connection_options.fetch(:connection_retry_sleep),
      "connection_timeout" => transport_connection_options.fetch(:timeout),
      "keepalive" => transport_connection_options.fetch(:keepalive),
      "keepalive_interval" => transport_connection_options.fetch(:keepalive_interval),
      "logger" => logger,
      "max_wait_until_ready" => transport_connection_options.fetch(:max_wait_until_ready),
      "sudo" => false,
      "sudo_command" => "sudo -E",
      "sudo_options" => "",
      attrs: nil,
      backend_cache: false
    }
      .tap do |options|
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend
          .call(
            hostname: kitchen_state.fetch(:kitchen_terraform_hostname),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost
          .call(
            hostname: kitchen_state.fetch(:kitchen_terraform_hostname),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort
          .call(
            group: kitchen_state.fetch(:kitchen_terraform_group),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerSSHKey
          .call(
            group: kitchen_state.fetch(:kitchen_terraform_group),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser
          .call(
            group: kitchen_state.fetch(:kitchen_terraform_group),
            options: options
          )
        options
          .store(
            :attributes,
            ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
              .call(
                group: kitchen_state.fetch(:kitchen_terraform_group),
                output: output
              )
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerControls
          .call(
            group: kitchen_state.fetch(:kitchen_terraform_group),
            options: options
          )
      end
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
