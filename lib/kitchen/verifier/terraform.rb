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
require "kitchen/terraform/group_and_hosts_enumerator"
require "kitchen/terraform/inspec_options_mapper"

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
#     [--attrs=group.attrs] \
#     --backend=group.backend \
#     [--backend-cache=group.backend_cache] \
#     [--no-color] \
#     [--controls=group.controls] \
#     [--enable-password=group.enable_password] \
#     --host=group.hosts_output.x \
#     [--key-files=group.key_files] \
#     [--password=group.password] \
#     [--path=group.path] \
#     [--port=group.port] \
#     [--profiles-path=test/integration/suite] \
#     [--user=group.user] \
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
    load_outputs kitchen_state: kitchen_state
    ::Kitchen::Terraform::GroupAndHostsEnumerator.new(groups: config_groups, outputs: outputs)
      .each_group_and_hosts do |group:, host:|
      verify group: group, host: host
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
    configure_inspec_connection_options
    configure_inspec_miscellaneous_options
  end

  private

  attr_accessor :inspec_options, :outputs

  # @api private
  def configure_inspec_connection_options
    inspec_options.merge! transport_connection_options

    inspec_options
      .store(
        "connection_timeout",
        inspec_options.delete("timeout")
      )
  end

  # @api private
  def configure_inspec_miscellaneous_options
    inspec_options.merge!(
      "color" => config_color,
      "distinct_exit" => false,
      "sudo" => false,
      "sudo_command" => "sudo -E",
      "sudo_options" => "",
    )
  end

  # @api private
  def load_outputs(kitchen_state:)
    self.outputs = ::Kitchen::Util.stringified_hash Hash kitchen_state.fetch :kitchen_terraform_outputs
  rescue ::KeyError
    raise(
      ::Kitchen::Terraform::Error,
      "The Kitchen state does not include :kitchen_terraform_outputs; this implies that the kitchen-terraform " \
      "provisioner has not successfully converged"
    )
  end

  # @api private
  def initialize(configuration = {})
    init_config configuration
    self.inspec_options = {}
  end

  # @api private
  def inspec_profile_path
    ::File
      .join(
        config.fetch(:test_base_path),
        instance
          .suite
          .name
      )
  end

  # load_needed_dependencies! loads the InSpec libraries required to verify a Terraform state.
  #
  # @api private
  # @raise [::Kitchen::ClientError] if loading the InSpec libraries fails.
  # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/configurable.rb#L252-L274
  def load_needed_dependencies!
    require "kitchen/terraform/inspec"
    ::Kitchen::Terraform::InSpec.logger = logger
  rescue ::LoadError => load_error
    raise(
      ::Kitchen::ClientError,
      load_error.message
    )
  end

  # @api private
  def transport_connection_options
    instance.transport.tap do |transport|
      return ::Kitchen::Util.stringified_hash(
               transport.send(:connection_options, transport.diagnose).dup.select do |key|
                 [
                   :compression,
                   :compression_level,
                   :connection_retries,
                   :connection_retry_sleep,
                   :timeout,
                   :keepalive,
                   :keepalive_interval,
                   :max_wait_until_ready,
                 ].include? key
               end
             )
    end
  end

  # @api private
  # @raise [::Kitchen::Terraform::Error] if running InSpec results in failure.
  def verify(group:, host:)
    info "Verifying host '#{host}' of group '#{group.fetch :name}'"
    inspec_options.store :host, host
    ::Kitchen::Terraform::InSpecOptionsMapper.new(group: group).map options: inspec_options
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes.call group: group, options: inspec_options,
                                                                         outputs: outputs
    ::Kitchen::Terraform::InSpec.new(options: inspec_options, path: inspec_profile_path).exec
  end
end

require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
