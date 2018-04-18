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
require "kitchen/verifier/inspec"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Verifier
module ::Kitchen::Verifier
end

# The verifier utilizes the {https://www.inspec.io/ InSpec infrastructure testing framework} to verify the behaviour and
# state of resources in the Terraform state.
#
# === Command-Line Interface
#
# The following actions are implemented by the verifier:
#
# * {#call kitchen verify}
#
# === Enable the Plugin
#
# The +verifier+ mapping must be declared with the plugin name within the
# {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}.
#
#   verifier:
#     name: terraform
#
# === Configuration
#
# The configuration of the verifier controls the behaviour of the InSpec runner.
#
# ==== color
#
# {include:Kitchen::Terraform::ConfigAttribute::Color}
#
# ==== groups
#
# {include:Kitchen::Terraform::ConfigAttribute::Groups}
#
# === InSpec Profiles
#
# The {https://www.inspec.io/docs/reference/profiles/ InSpec profile} for a
# {https://kitchen.ci/docs/getting-started/kitchen-yml Kitchen Suite} must be defined under
# +./test/integration/<suite>/+.
class ::Kitchen::Verifier::Terraform < ::Kitchen::Verifier::Inspec
  kitchen_verifier_api_version 2

  include ::Kitchen::Terraform::ConfigAttribute::Color

  include ::Kitchen::Terraform::ConfigAttribute::Groups

  include ::Kitchen::Terraform::Configurable

  # This action verifies the Kitchen Instance by executing the InSpec controls of each group.
  # === Workflow
  #
  # ==== Executing the InSpec Controls of a Group
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
  # @example Describe the verify action
  #   kitchen help verify
  # @example Verify a Kitchen Instance named default-ubuntu
  #   kitchen verify default-ubuntu
  # @param kitchen_state [::Hash] the Kitchen state is queried for the Terraform output.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [self]
  def call(kitchen_state)
    enumerate_groups_and_hostnames kitchen_state: kitchen_state do
      super kitchen_state
    end

    self
  rescue ::Kitchen::StandardError => error
    action_failed error: error
  end

  private

  attr_accessor(
    :group,
    :hostname,
    :inspec_runner_options,
    :kitchen_state
  )

  # @api private
  def enumerate_groups_and_hostnames(kitchen_state:)
    self.kitchen_state = kitchen_state

    ::Kitchen::Verifier::Terraform::EnumerateGroupsAndHostnames
      .call(
        groups: config_groups,
        output: output
      ) do |group:, hostname:|
        prepare_to_verify(
          group: group,
          hostname: hostname
        )

        yield
      end
  end

  # @api private
  def apply_kitchen_terraform_runner_options
    configure_inspec_runner_profile
    configure_inspec_runner_transport
  end

  # @api private
  def configure_inspec_runner_attributes
    inspec_runner_options
      .store(
        :attributes,
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
          .call(
            group: group,
            output: output
          )
      )
  end

  # @api private
  def configure_inspec_runner_backend
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend
      .call(
        hostname: hostname,
        options: inspec_runner_options
      )
  end

  # @api private
  def configure_inspec_runner_controls
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerControls
      .call(
        group: group,
        options: inspec_runner_options
      )
  end

  # @api private
  def configure_inspec_runner_host
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost
      .call(
        hostname: hostname,
        options: inspec_runner_options
      )
  end

  # @api private
  def configure_inspec_runner_port
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort
      .call(
        group: group,
        options: inspec_runner_options
      )
  end

  # @api private
  def configure_inspec_runner_profile
    configure_inspec_runner_attributes
    configure_inspec_runner_controls
  end

  # @api private
  def configure_inspec_runner_ssh_key
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerSSHKey
      .call(
        group: group,
        options: inspec_runner_options
      )
  end

  # @api private
  def configure_inspec_runner_transport
    configure_inspec_runner_backend
    configure_inspec_runner_host
    configure_inspec_runner_port
    configure_inspec_runner_ssh_key
    configure_inspec_runner_user
  end

  # @api private
  def configure_inspec_runner_user
    ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser
      .call(
        group: group,
        options: inspec_runner_options
      )
  end

  # @api private
  def output
    ::Kitchen::Util
      .stringified_hash(
        kitchen_state
          .fetch(:kitchen_terraform_output) do
            raise(
              ::Kitchen::ActionFailed,
              "The Kitchen state does not include :kitchen_terraform_output; this implies that the Terraform " \
                "provisioner has not successfully converged"
            )
          end
      )
  end

  # @api private
  def prepare_to_verify(group:, hostname:)
    self.group = group
    self.hostname = hostname
    info "Verifying host '#{hostname}' of group '#{group.fetch :name}'"
    self
  end

  # Modifies the Inspec Runner options generated by the kitchen-inspec verifier to support the verification of each
  # group's hosts.
  #
  # @api private
  # @return [::Hash] Inspec Runner options.
  # @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb ::Inspec::Runner
  def runner_options(transport, kitchen_state = {}, platform = nil, suite = nil)
    self.inspec_runner_options = super
    apply_kitchen_terraform_runner_options
    inspec_runner_options
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
