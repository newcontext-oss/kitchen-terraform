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
require "fileutils"
require "json"
require "kitchen"
require "kitchen/terraform/clear_directory"
require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options"
require "kitchen/terraform/client_version_verifier"
require "kitchen/terraform/config_attribute/backend_configurations"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/command_timeout"
require "kitchen/terraform/config_attribute/directory"
require "kitchen/terraform/config_attribute/lock_timeout"
require "kitchen/terraform/config_attribute/parallelism"
require "kitchen/terraform/config_attribute/plugin_directory"
require "kitchen/terraform/config_attribute/state"
require "kitchen/terraform/config_attribute/variable_files"
require "kitchen/terraform/config_attribute/variables"
require "kitchen/terraform/config_attribute/verify_plugins"
require "kitchen/terraform/create_directories"
require "terraform/configurable"

# The kitchen-terraform driver is the bridge between Test Kitchen and Terraform.
#
# It manages the state of the configured root Terraform module by invoking its workflow in a constructive or destructive
# manner.
#
# === Test Kitchen Configuration
#
# The configuration of the driver is used to control the behaviour of the Terraform Client commands.
#
# More information about the available configuration attributes is located with the respective modules.
#
# Test Kitchen configuration is defined in +.kitchen.yml+ and optionally overridden in +.kitchen.local.yml+.
#
# ==== Example
#
#   driver:
#     name: "terraform"
#     backend_configurations:
#       argument_name: "argument_value"
#     command_timeout: 1000
#     color: false
#     directory: "/directory/containing/terraform/configuration"
#     lock_timeout: 2000
#     parallelism: 2
#     plugin_directory: "/plugin/directory"
#     state: "/terraform/state"
#     variable_files:
#       - "/first/terraform/variable/file"
#       - "/second/terraform/variable/file"
#     variables:
#       variable_name: "variable_value"
#     verify_plugins: false
#
# @see ::Kitchen::Terraform::Client::Command
# @see ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations
# @see ::Kitchen::Terraform::ConfigAttribute::CommandTimeout
# @see ::Kitchen::Terraform::ConfigAttribute::Color
# @see ::Kitchen::Terraform::ConfigAttribute::Directory
# @see ::Kitchen::Terraform::ConfigAttribute::LockTimeout
# @see ::Kitchen::Terraform::ConfigAttribute::Parallelism
# @see ::Kitchen::Terraform::ConfigAttribute::PluginDirectory
# @see ::Kitchen::Terraform::ConfigAttribute::State
# @see ::Kitchen::Terraform::ConfigAttribute::VariableFiles
# @see ::Kitchen::Terraform::ConfigAttribute::Variables
# @see ::Kitchen::Terraform::ConfigAttribute::VerifyPlugins
# @see http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen: .kitchen.yml
# @version 2
class ::Kitchen::Driver::Terraform < ::Kitchen::Driver::Base
  kitchen_driver_api_version 2

  no_parallel_for

  include ::Dry::Monads::Either::Mixin

  include ::Dry::Monads::Try::Mixin

  include ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations

  include ::Kitchen::Terraform::ConfigAttribute::Color

  include ::Kitchen::Terraform::ConfigAttribute::CommandTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Directory

  include ::Kitchen::Terraform::ConfigAttribute::LockTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Parallelism

  include ::Kitchen::Terraform::ConfigAttribute::PluginDirectory

  include ::Kitchen::Terraform::ConfigAttribute::State

  include ::Kitchen::Terraform::ConfigAttribute::VariableFiles

  include ::Kitchen::Terraform::ConfigAttribute::Variables

  include ::Kitchen::Terraform::ConfigAttribute::VerifyPlugins

  include ::Terraform::Configurable

  # The driver invokes its workflow in a constructive manner by applying changes to the Terraform state.
  #
  # @example
  #   `kitchen help create`
  # @example
  #   `kitchen create suite-name`
  # @note The user must ensure that different suites utilize separate Terraform state files if they are to run
  #       the create action concurrently.
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @see ::Kitchen::Driver::Terraform#run_apply
  # @see ::Kitchen::Driver::Terraform#workflow
  def create(_state)
    workflow do
      run_apply
    end
  end

  # The driver invokes its workflow in a destructive manner by destroying the Terraform state and removing the instance
  # directory.
  #
  # @example
  #   `kitchen help destroy`
  # @example
  #   `kitchen destroy suite-name`
  # @note The user must ensure that different suites utilize separate Terraform state files if they are to run
  #       the destroy action concurrently.
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @see ::Kitchen::Driver::Terraform#remove_instance_directory
  # @see ::Kitchen::Driver::Terraform#run_destroy
  # @see ::Kitchen::Driver::Terraform#workflow
  def destroy(_state)
    workflow do
      run_destroy.bind do
        remove_instance_directory
      end
    end
  end

  # The driver parses the Terraform Client output subcomannd output as JSON.
  #
  # @return [::Dry::Monads::Either] the result of parsing the output.
  # @see ::Kitchen::Terraform::Client::Command.Output
  # @see ::JSON.parse
  def output
    run_output
      .bind do |output|
        Try ::JSON::ParserError do
          ::JSON.parse output
        end
          .to_either
      end
      .or do |error|
        Left "parsing Terraform client output as JSON failed\n#{error}"
      end
  end

  # The driver verifies that the client version is supported.
  #
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @see ::Kitchen::Terraform::Client::Command.version
  # @see ::Kitchen::Terraform::ClientVersionVerifier#verify
  def verify_dependencies
    run_version
      .bind do |output|
        ::Kitchen::Terraform::ClientVersionVerifier
          .new
          .verify version_output: output
      end
      .bind do |verified_client_version|
        Right logger.warn verified_client_version
      end
      .or do |failure|
        raise(
          ::Kitchen::UserError,
          failure
        )
      end
  end

  private

  # The driver creates the instance directory or clears it of Terraform configuration if it already exists.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of creating or clearing the instance directory.
  # @see ::KItchen::Terraform::ClearDirectory.call
  # @see ::Kitchen::Driver::Terraform#instance_directory
  # @see ::Kitchen::Terraform::CreateDirectories.call
  def prepare_instance_directory
    ::Kitchen::Terraform::CreateDirectories
      .call(
        directories: [instance_directory]
      )
      .bind do |created_directories|
        logger.debug created_directories
        ::Kitchen::Terraform::ClearDirectory
          .call(
            directory: instance_directory,
            files: [
              "*.tf",
              "*.tf.json"
            ]
          )
      end
      .bind do |cleared_directory|
        Right logger.debug cleared_directory
      end
  end

  # The driver removes the instance directory.
  #
  # @api private
  # @see ::FileUtils.remove_dir
  # @see ::Kitchen::Driver::Terraform#instance_directory
  def remove_instance_directory
    Try do
      ::FileUtils.remove_dir instance_directory
    end
      .to_either
  end

  # Runs a Terraform Client command shell out with the default logger and the configured timeout.
  #
  # @api private
  # @param result [::Dry::Monads::Either] the result of a shell out creation
  # @return [::Dry::Monads::Either] the result of running the shell out
  def run(result:)
    result
      .bind do |shell_out|
        ::Kitchen::Terraform::Client::Command
          .run(
            logger: logger,
            shell_out: shell_out,
            timeout: config_command_timeout
          )
      end
  end

  # Runs the Terraform Client apply subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the apply subcommand.
  # @see ::Kitchen::Terraform::Client::Command.apply
  def run_apply
    run(
      result:
        ::Kitchen::Terraform::Client::Command
          .apply(
            options:
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
                .var_files(paths: config_variable_files),
            working_directory: instance_directory
          )
    )
  end

  # Runs the Terraform Client destroy subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the destroy subcommand.
  # @see ::Kitchen::Terraform::Client::Command.destroy
  def run_destroy
    run(
      result:
        ::Kitchen::Terraform::Client::Command
          .destroy(
            options:
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
                .force,
            working_directory: instance_directory
          )
    )
  end

  # Runs the Terraform Client init subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the init subcommand.
  # @see ::Kitchen::Terraform::Client::Command.init
  def run_init
    run(
      result:
        ::Kitchen::Terraform::Client::Command
          .init(
            options:
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
                .verify_plugins(toggle: config_verify_plugins),
            working_directory: instance_directory
          )
    )
  end

  # Runs the Terraform Client output subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the init subcommand.
  # @see ::Kitchen::Terraform::Client::Command.output
  def run_output
    run(
      result:
        ::Kitchen::Terraform::Client::Command.output(
          options:
            ::Kitchen::Terraform::Client::Options
              .new
              .json
              .state(path: config_state),
          working_directory: instance_directory
        )
    )
  end

  # Runs the Terraform Client validate subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the validate subcommand.
  # @see ::Kitchen::Terraform::Client::Command.validate
  def run_validate
    run(
      result:
        ::Kitchen::Terraform::Client::Command
          .validate(
            options:
              ::Kitchen::Terraform::Client::Options
                .new
                .enable_check_variables
                .maybe_no_color(toggle: !config_color)
                .vars(keys_and_values: config_variables)
                .var_files(paths: config_variable_files),
            working_directory: instance_directory
          )
    )
  end

  # Runs the Terraform Client version subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the version subcommand.
  # @see ::Kitchen::Terraform::Client::Command.version
  def run_version
    run result: ::Kitchen::Terraform::Client::Command.version(working_directory: config.fetch(:kitchen_root))
  end

  # Memoizes the path to the Test Kitchen suite instance directory at `.kitchen/kitchen-terraform/<suite>-<platform>`.
  #
  # @api private
  # @return [::String] the path to the Test Kitchen suite instance directory.
  def instance_directory
    @instance_directory ||= instance_pathname filename: "/"
  end

  # 1. Prepares the instance directory
  # 2. Executes `terraform init` in the instance directory
  # 3. Executes `terraform validate` in the instance directory
  # 4. Executes a provided subcommand in the instance directory
  #
  # @api private
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @see ::Kitchen::Driver::Terraform#prepare_instance_directory
  # @see ::Kitchen::Driver::Terraform#run_init
  # @see ::Kitchen::Driver::Terraform#run_validate
  # @yieldreturn [::Dry::Monads::Either] the result of a Terraform Client subcommand.
  def workflow
    prepare_instance_directory
      .bind do
        run_init
      end
      .bind do
        run_validate
      end
      .bind do
        yield
      end
      .or do |failure|
        raise(
          ::Kitchen::ActionFailed,
          failure
        )
      end
  end
end
