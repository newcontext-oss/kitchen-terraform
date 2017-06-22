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

require "dry/monads"
require "kitchen"
require "kitchen/terraform/define_config_attribute"
require "kitchen/verifier/inspec"
require "terraform/configurable"

# The verifier utilizes the InSpec infrastructure testing framework to verify the behaviour and state of resources in
# the Terraform state.
#
# === Configuration
#
# ==== Example .kitchen.yml snippet
#
#   verifier:
#     name: terraform
#     groups:
#       - name: group_one
#         attributes:
#           foo: bar
#         controls:
#           - biz
#         hostnames: hostnames_output
#         port: 123
#         username: test-user
#       - name: group_two
#
# ==== Attributes
#
# ===== groups
#
# Description:: A collection of maps that configure which InSpec profile will be run against different resources in the
#               Terraform state.
#
# Type:: Array
#
# Status:: Optional
#
# Default:: +[]+
#
# ====== name
#
# Description:: A label that is used to identify the group.
#
# Type:: String
#
# Status:: Required
#
# ====== attributes
#
# Description:: A map that associates InSpec profile attribute names to Terraform output variable names.
#
# Type:: Hash
#
# Status:: Optional
#
# Default:: +{}+
#
# ====== controls
#
# Description:: A collection of controls to selectively include from the suite's InSpec profile.
#
# Type:: Array
#
# Status:: Optional
#
# Default:: +[]+
#
# ====== hostnames
#
# Description:: The name of a Terraform output variable of type String or Array which contains one or more hostnames
#               from the Terraform state that will be targeted with the suite's InSpec profile.
#
# Type:: String
#
# Status:: Optional
#
# ====== port
#
# Description:: The port to use when connecting to the group's hosts with Secure Shell (SSH).
#
# Type:: Integer
#
# Status:: Optional
#
# ====== username
#
# Description:: The username to use when connecting to the group's hosts with SSH.
#
# Type:: String
#
# Status:: Optional
#
# @see https://en.wikipedia.org/wiki/Secure_Shell Secure Shell
# @see https://www.inspec.io/ InSpec
# @see https://www.inspec.io/docs/reference/dsl_inspec/ InSpec Controls
# @see https://www.inspec.io/docs/reference/profiles/ InSpec Profiles
# @see https://www.terraform.io/docs/configuration/outputs.html Terraform Output Variables
# @see https://www.terraform.io/docs/state/index.html Terraform State
# @version 2
class ::Kitchen::Verifier::Terraform < ::Kitchen::Verifier::Inspec
  kitchen_verifier_api_version 2

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :groups,
    initialize_default_value: lambda do |_plugin|
      []
    end,
    plugin_class: self,
    schema: lambda do
      configure do
        def self.messages
          super.merge en: {
            errors: {
              keys_are_strings_or_symbols?: "keys must be strings or symbols",
              values_are_strings?: "values must be strings"
            }
          }
        end

        def keys_are_strings_or_symbols?(hash)
          hash.keys.all? do |key|
            key.is_a?(::String) | key.is_a?(::Symbol)
          end
        end

        def values_are_strings?(hash)
          hash.values.all? do |value|
            value.is_a? ::String
          end
        end
      end
      required(:value).each do
        schema do
          required(:name).filled :str?
          optional(:attributes).value :hash?, :keys_are_strings_or_symbols?, :values_are_strings?
          optional(:controls).each :filled?, :str?
          optional(:hostnames).value :str?
          optional(:port).value :int?
          optional(:username).value :str?
        end
      end
    end
  )

  include ::Dry::Monads::Either::Mixin

  include ::Terraform::Configurable

  # The verifier enumerates through each hostname of each group and verifies the associated InSpec controls.
  #
  # @example
  #   `kitchen verify suite-name`
  # @param state [::Hash] the mutable instance and verifier state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [::Dry::Monads::Either] the result of the action.
  def call(state)
    self.class::EnumerateGroupsAndHostnames.call driver: driver, groups: config.fetch(:groups) do |group:, hostname:|
      state.store :group, group
      state.store :hostname, hostname
      info "Verifying host '#{hostname}' of group '#{group.fetch :name}'"
      super state
    end.fmap do |success|
      logger.debug success
    end.or do |failure|
      raise ::Kitchen::ActionFailed, failure
    end
  end

  private

  # Modifies the Inspec Runner options generated by the kitchen-inspec verifier to support the verification of each
  # group's hosts.
  #
  # @api private
  # @return [::Hash] Inspec Runner options.
  # @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb ::Inspec::Runner
  # @see https://github.com/chef/kitchen-inspec/blob/master/lib/kitchen/verifier.rb kitchen-inspec verifier
  def runner_options(transport, state = {}, platform = nil, suite = nil)
    super(transport, state, platform, suite).tap do |options|
      self.class::ConfigureInspecRunnerBackend.call hostname: state.fetch(:hostname), options: options
      self.class::ConfigureInspecRunnerHost.call hostname: state.fetch(:hostname), options: options
      self.class::ConfigureInspecRunnerPort.call group: state.fetch(:group), options: options
      self.class::ConfigureInspecRunnerUser.call group: state.fetch(:group), options: options
      self.class::ConfigureInspecRunnerAttributes
        .call(driver: driver, group: state.fetch(:group), terraform_state: driver[:state]).bind do |attributes|
          config.store :attributes, attributes
        end
      self.class::ConfigureInspecRunnerControls.call group: state.fetch(:group), options: options
    end
  end
end

require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "kitchen/verifier/terraform/configure_inspec_runner_backend"
require "kitchen/verifier/terraform/configure_inspec_runner_controls"
require "kitchen/verifier/terraform/configure_inspec_runner_host"
require "kitchen/verifier/terraform/configure_inspec_runner_port"
require "kitchen/verifier/terraform/configure_inspec_runner_user"
require "kitchen/verifier/terraform/enumerate_groups_and_hostnames"
