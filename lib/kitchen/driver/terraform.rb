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
require "json"
require "kitchen"
require "kitchen/terraform/clear_directory"
require "kitchen/terraform/create_directories"
require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options"
require "kitchen/terraform/define_array_of_strings_config_attribute"
require "kitchen/terraform/define_hash_of_symbols_and_strings_config_attribute"
require "kitchen/terraform/define_config_attribute"
require "kitchen/terraform/define_integer_config_attribute"
require "kitchen/terraform/define_optional_file_path_config_attribute"
require "kitchen/terraform/define_string_config_attribute"
require "terraform/configurable"

# The kitchen-terraform driver is the bridge between Test Kitchen and Terraform. It manages the state of the configured
# root Terraform module by invoking its workflow in a constructive or destructive manner.
#
# === Configuration
#
# ==== Example .kitchen.yml snippet
#
#   driver:
#     name: terraform
#     command_timeout: 1000
#     color: false
#     directory: /directory/containing/terraform/configuration
#     parallelism: 2
#     state: /terraform/state
#     variable_files:
#       - /first/terraform/variable/file
#       - /second/terraform/variable/file
#     variables:
#       variable_name: variable_value
#
# ==== Attributes
#
# ===== color
#
# Description:: Toggle to enable or disable colored output from the Terraform CLI commands.
#
# Type:: Boolean
#
# Status:: Optional
#
# Default:: +true+ if the Test Kitchen process is associated with a terminal device (tty); +false+ if it is not.
#
# ===== command_timeout
#
# Description:: The number of seconds to wait for the Terraform CLI commands to finish.
#
# Type:: Integer
#
# Status:: Optional
#
# Default:: +600+
#
# ===== directory
#
# Description:: The path of the directory containing the root Terraform module to be tested.
#
# Type:: String
#
# Status:: Optional
#
# Default:: The working directory of the Test Kitchen process.
#
# ===== parallelism
#
# Description:: The maximum number of concurrent operations to allow while walking the resource graph for the Terraform
#               CLI apply commands.
# Type:: Integer
#
# Status:: Optional
#
# Default:: +10+
#
# ===== plugin_directory
#
# Description:: The path of the directory containing customized Terraform provider plugins to install in place of the
#               official Terraform provider plugins.
#
# Type:: String
#
# Status:: Optional
#
# ===== state
#
# Description:: The path of the Terraform state that will be generated and managed.
#
# Type:: String
#
# Status:: Optional
#
# Default:: A descendant of the working directory of the Test Kitchen process:i
#           +".kitchen/kitchen-terraform/<suite_name>/terraform.tfstate"+.
#
# ===== variable_files
#
# Description:: A collection of paths of Terraform variable files to be evaluated during the application of Terraform
#               state changes.
#
# Type:: Array
#
# Status:: Optional
#
# Default:: +[]+
#
# ===== variables
#
# Description:: A mapping of Terraform variable names and values to be overridden during the application of Terraform
#               state changes.
#
# Type:: Hash
#
# Status:: Optional
#
# Default:: +{}+
#
# @see https://en.wikipedia.org/wiki/Working_directory Working directory
# @see https://www.terraform.io/docs/commands/init.html#plugin-installation Terraform plugin installation
# @see https://www.terraform.io/docs/configuration/variables.html Terraform variables
# @see https://www.terraform.io/docs/internals/graph.html Terraform resource graph
# @see https://www.terraform.io/docs/state/index.html Terraform state
# @version 2
class ::Kitchen::Driver::Terraform < ::Kitchen::Driver::Base
  kitchen_driver_api_version 2

  no_parallel_for

  ::Kitchen::Terraform::DefineHashOfSymbolsAndStringsConfigAttribute.call(
    attribute: :backend_configurations,
    plugin_class: self
  )

  ::Kitchen::Terraform::DefineIntegerConfigAttribute.call attribute: :command_timeout,
                                                          plugin_class: self do
    600
  end

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :color,
    initialize_default_value: lambda do |_plugin|
      ::Kitchen.tty?
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :bool?
    end
  )

  ::Kitchen::Terraform::DefineStringConfigAttribute.call attribute: :directory,
                                                         expand_path: true,
                                                         plugin_class: self do
    "."
  end

  ::Kitchen::Terraform::DefineStringConfigAttribute.call attribute: :lock_timeout,
                                                         plugin_class: self do
    "0s"
  end

  ::Kitchen::Terraform::DefineIntegerConfigAttribute.call attribute: :parallelism,
                                                          plugin_class: self do
    10
  end

  ::Kitchen::Terraform::DefineOptionalFilePathConfigAttribute.call(
    attribute: :plugin_directory,
    plugin_class: self
  )

  ::Kitchen::Terraform::DefineStringConfigAttribute.call attribute: :state,
                                                         expand_path: true,
                                                         plugin_class: self do |plugin|
    plugin.instance_pathname filename: "terraform.tfstate"
  end

  ::Kitchen::Terraform::DefineArrayOfStringsConfigAttribute.call attribute: :variable_files,
                                                                 expand_path: true,
                                                                 plugin_class: self do
    []
  end

  ::Kitchen::Terraform::DefineHashOfSymbolsAndStringsConfigAttribute.call(
    attribute: :variables,
    plugin_class: self
  )

  include ::Dry::Monads::Either::Mixin

  include ::Dry::Monads::Try::Mixin

  include ::Terraform::Configurable

  # The driver invokes its workflow in a constructive manner.
  #
  # @example
  #   `kitchen create suite-name`
  # @note The user must ensure that different suites utilize separate Terraform state files if they are to run
  #       the create action concurrently.
  # @param _state [::Hash] the mutable instance and driver state; this parameter is ignored.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [::Dry::Monads::Either] the result of the action.
  def create(_state, additional_plan_options: [])
    ::Kitchen::Terraform::CreateDirectories.call(
      directories: [
        module_path,
        config_directory,
        ::File.dirname(config_plan),
        ::File.dirname(config_state)
      ]
    ) do |created_directories|
      logger.debug created_directories
      ::Kitchen::Terraform::ClearDirectory.call(
        directory: module_path,
        files: [
          "*.tf",
          "*.tf.json"
        ]
      ) do |cleared_directory|
        logger.debug cleared_directory
        ::Kitchen::Terraform::Client::Command.validate(
          logger: logger,
          target: config_directory,
          timeout: config_command_timeout,
          working_directory: config_kitchen_root
        ) do
          ::Kitchen::Terraform::Client::Command.init(
            logger: logger,
            options: [
              ::Kitchen::Terraform::Client::Options::Backend.new(value: true),
              *config_backend_configurations.map do |value|
                ::Kitchen::Terraform::Client::Options::BackendConfig.new value: value
              end,
              ::Kitchen::Terraform::Client::Options::ForceCopy.new,
              ::Kitchen::Terraform::Client::Options::Get.new(value: true),
              ::Kitchen::Terraform::Client::Options::Input.new(value: false),
              ::Kitchen::Terraform::Client::Options::Lock.new(value: true),
              ::Kitchen::Terraform::Client::Options::LockTimeout.new(value: config_lock_timeout),
              color_option,
              ::Kitchen::Terraform::Client::Options::Reconfigure.new
            ],
            target: "#{config_directory} #{module_path}",
            timeout: config_command_timeout,
            working_directory: config_kitchen_root
          ) do
            ::Kitchen::Terraform::Client::Command.plan(
              logger: logger,
              options: [
                ::Kitchen::Terraform::Client::Options::Input.new(value: false),
                color_option,
                ::Kitchen::Terraform::Client::Options::Out.new(value: config_plan),
                ::Kitchen::Terraform::Client::Options::Parallelism.new(value: config_parallelism),
                ::Kitchen::Terraform::Client::Options::State.new(value: config_state),
                *config_variables.map do |name, value|
                  ::Kitchen::Terraform::Client::Options::Var.new name: name, value: value
                end,
                *config_variable_files.map do |value|
                  ::Kitchen::Terraform::Client::Options::VarFile.new value: value
                end,
                *additional_plan_options
              ],
              target: module_path,
              timeout: config_command_timeout,
              working_directory: module_path
            ) do
              ::Kitchen::Terraform::Client::Command.apply(
                logger: logger,
                options: [
                  ::Kitchen::Terraform::Client::Options::Input.new(value: false),
                  color_option,
                  ::Kitchen::Terraform::Client::Options::Parallelism.new(value: config_parallelism),
                  ::Kitchen::Terraform::Client::Options::StateOut.new(value: config_state)
                ],
                target: config_plan,
                timeout: config_command_timeout,
                working_directory: module_path
              ) do
                Right logger.debug "#{self}.create resulted in success"
              end
            end
          end
        end
      end
    end.or do |failure|
      raise ::Kitchen::ActionFailed, failure
    end
  end

  # The driver invokes its workflow in a destructive manner.
  #
  # @example
  #   `kitchen destroy suite-name`
  # @note The user must ensure that different suites utilize separate Terraform state files if they are to run
  #       the destroy action concurrently.
  # @param state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [::Dry::Monads::Either] the result of the action.
  def destroy(state)
    create state, additional_plan_options: [
                    ::Kitchen::Terraform::Client::Options::Destroy.new
                  ]
  end

  # The driver parses the client output as JSON.
  #
  # @return [::Dry::Monads::Either] the result of the Terraform Client Output function.
  # @see ::Kitchen::Terraform::Client::Output
  def output
    ::Kitchen::Terraform::Client::Command.output(
      logger: debug_logger,
      options: [
        color_option,
        ::Kitchen::Terraform::Client::Options::JSON.new,
        ::Kitchen::Terraform::Client::Options::State.new(value: config_state)
      ],
      timeout: config_command_timeout,
      working_directory: module_path
    ) do |output|
      Try ::JSON::ParserError do
        ::JSON.parse output
      end.to_either
    end.or do |error|
      Left "parsing Terraform client output as JSON failed\n#{error}"
    end
  end

  # The driver verifies that the client version is supported.
  #
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @see ::Kitchen::Driver::Terraform::VerifyClientVersion
  # @see ::Kitchen::Terraform::Client::Version
  def verify_dependencies
    ::Kitchen::Terraform::Client::Command.version(
      logger: debug_logger,
      working_directory: ::Dir.pwd
    ) do |output|
      self.class::VerifyClientVersion.call version: output
    end.fmap do |verified_client_version|
      logger.warn verified_client_version
    end.or do |failure|
      raise ::Kitchen::UserError, failure
    end
  end

  private

  def apply_options
    ::Kitchen::Terraform::Client::Options
      .new
      .enable_lock
      .lock_timeout(duration: config_lock_timeout)
      .disable_input
      .enable_auto_approve
      .maybe_no_color(toggle: !config_color)
      .parallelism(concurrent_operations: config_parallelism)
      .enable_refresh
      .state(path: config_state)
      .state_out(path: config_state)
      .vars(keys_and_values: config_variables)
      .var_files(paths: config_variable_files)
  end

  def config_kitchen_root
    @config_kitchen_root ||= config.fetch :kitchen_root
  end

  def destroy_options
    ::Kitchen::Terraform::Client::Options
      .new
      .enable_lock
      .lock_timeout(duration: config_lock_timeout)
      .disable_input
      .maybe_no_color(toggle: !config_color)
      .parallelism(concurrent_operations: config_parallelism)
      .enable_refresh
      .state(path: config_state)
      .state_out(path: config_state)
      .vars(keys_and_values: config_variables)
      .var_files(paths: config_variable_files)
      .force
  end

  def init_options
    ::Kitchen::Terraform::Client::Options
      .new
      .disable_input
      .enable_lock
      .lock_timeout(duration: config_lock_timeout)
      .maybe_no_color(toggle: !config_color)
      .upgrade
      .from_module(source: config_directory)
      .enable_backend
      .force_copy
      .backend_configs(keys_and_values: config_backend_configurations)
      .enable_get
      .maybe_plugin_dir(path: config_plugin_directory)
  end

  def instance_directory
    @instance_directory ||= instance_pathname filename: "/"
  end

  def output_options
    ::Kitchen::Terraform::Client::Options
      .new
      .json
      .state(path: config_state)
  end

  def validate_options
    ::Kitchen::Terraform::Client::Options
      .new
      .enable_check_variables
      .maybe_no_color(toggle: !config_color)
      .vars(keys_and_values: config_variables)
      .var_files(paths: config_variable_files)
  end
end

require "kitchen/driver/terraform/verify_client_version"
