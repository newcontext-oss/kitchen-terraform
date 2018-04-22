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

require "kitchen/driver/base"
require "kitchen/errors"
require "kitchen/terraform/client_version_verifier"
require "kitchen/terraform/command/output"
require "kitchen/terraform/config_attribute/backend_configurations"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/command_timeout"
require "kitchen/terraform/config_attribute/lock"
require "kitchen/terraform/config_attribute/lock_timeout"
require "kitchen/terraform/config_attribute/parallelism"
require "kitchen/terraform/config_attribute/plugin_directory"
require "kitchen/terraform/config_attribute/root_module_directory"
require "kitchen/terraform/config_attribute/variable_files"
require "kitchen/terraform/config_attribute/variables"
require "kitchen/terraform/configurable"
require "kitchen/terraform/shell_out"
require "shellwords"

# The driver is the bridge between Test Kitchen and Terraform. It manages the
# {https://www.terraform.io/docs/state/index.html state} of the Terraform root module by shelling out and running
# Terraform commands.
#
# === Commands
#
# The following command-line commands are provided by the driver.
#
# ==== kitchen create
#
# A Test Kitchen instance is created through the following steps.
#
# ===== Initializing the Terraform Working Directory
#
#   terraform init \
#     -input=false \
#     -lock=<lock> \
#     -lock-timeout=<lock_timeout>s \
#     [-no-color] \
#     -upgrade \
#     -force-copy \
#     -backend=true \
#     [-backend-config=<backend_configurations.first> ...] \
#     -get=true \
#     -get-plugins=true \
#     [-plugin-dir=<plugin_directory>] \
#     -verify-plugins=true \
#     <root_module_directory>
#
# ===== Creating a Test Terraform Workspace
#
#   terraform workspace <new|select> kitchen-terraform-<instance>
#
# ==== kitchen destroy
#
# A Test Kitchen instance is destroyed through the following steps.
#
# ===== Initializing the Terraform Working Directory
#
#   terraform init \
#     -input=false \
#     -lock=<lock> \
#     -lock-timeout=<lock_timeout>s \
#     [-no-color] \
#     -force-copy \
#     -backend=true \
#     [-backend-config=<backend_configurations.first>...] \
#     -get=true \
#     -get-plugins=true \
#     [-plugin-dir=<plugin_directory>] \
#     -verify-plugins=true \
#     <root_module_directory>
#
# ===== Selecting the Test Terraform Workspace
#
#   terraform workspace <select|new> kitchen-terraform-<instance>
#
# ===== Destroying the Terraform State
#
#   terraform destroy \
#     -force \
#     -lock=<lock> \
#     -lock-timeout=<lock_timeout>s \
#     -input=false \
#     [-no-color] \
#     -parallelism=<parallelism> \
#     -refresh=true \
#     [-var=<variables.first>...] \
#     [-var-file=<variable_files.first>...] \
#     <root_module_directory>
#
# ===== Selecting the Default Terraform Workspace
#
#   terraform workspace select default
#
# ===== Deleting the Test Terraform Workspace
#
#   terraform workspace delete kitchen-terraform-<instance>
#
# === Shelling Out
#
# {include:Kitchen::Terraform::ShellOut}
#
# === Configuration Attributes
#
# The configuration attributes of the driver control the behaviour of the Terraform commands that are run. Within the
# {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}, these attributes must be
# declared in the +driver+ mapping along with the plugin name.
#
#   driver:
#     name: terraform
#     a_configuration_attribute: some value
#
# ==== backend_configurations
#
# {include:Kitchen::Terraform::ConfigAttribute::BackendConfigurations}
#
# ==== color
#
# {include:Kitchen::Terraform::ConfigAttribute::Color}
#
# ==== command_timeout
#
# {include:Kitchen::Terraform::ConfigAttribute::CommandTimeout}
#
# ==== lock
#
# {include:Kitchen::Terraform::ConfigAttribute::Lock}
#
# ==== lock_timeout
#
# {include:Kitchen::Terraform::ConfigAttribute::LockTimeout}
#
# ==== parallelism
#
# {include:Kitchen::Terraform::ConfigAttribute::Parallelism}
#
# ==== plugin_directory
#
# {include:Kitchen::Terraform::ConfigAttribute::PluginDirectory}
#
# ==== root_module_directory
#
# {include:Kitchen::Terraform::ConfigAttribute::RootModuleDirectory}
#
# ==== variable_files
#
# {include:Kitchen::Terraform::ConfigAttribute::VariableFiles}
#
# ==== variables
#
# {include:Kitchen::Terraform::ConfigAttribute::Variables}
#
# @example Describe the create command
#   kitchen help create
# @example Create a Test Kitchen instance
#   kitchen create default-ubuntu
# @example Describe the destroy command
#   kitchen help destroy
# @example Destroy a Test Kitchen instance
#   kitchen destroy default-ubuntu
# @version 2
class ::Kitchen::Driver::Terraform < ::Kitchen::Driver::Base
  kitchen_driver_api_version 2

  include ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations

  include ::Kitchen::Terraform::ConfigAttribute::Color

  include ::Kitchen::Terraform::ConfigAttribute::CommandTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Lock

  include ::Kitchen::Terraform::ConfigAttribute::LockTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Parallelism

  include ::Kitchen::Terraform::ConfigAttribute::PluginDirectory

  include ::Kitchen::Terraform::ConfigAttribute::RootModuleDirectory

  include ::Kitchen::Terraform::ConfigAttribute::VariableFiles

  include ::Kitchen::Terraform::ConfigAttribute::Variables

  include ::Kitchen::Terraform::Configurable

  # This method queries for the names of the action methods which must be run in serial via a shared mutex.
  #
  # If the version satisfies the requirement of ~> 3.3 then no names are returned.
  #
  # If the version satisfies the requirement of >= 4 then +:create+, +:converge+, +:setup+, and +:destroy+ are returned.
  #
  # @param version [::Kitchen::Terraform::Version] the version to compare against the requirements.
  # @return [::Array<Symbol>] the action method names.
  def self.serial_actions(version: ::Kitchen::Terraform::Version.new)
    version
      .if_satisfies requirement: ::Gem::Requirement.new("~> 3.3") do
        no_parallel_for
      end

    version
      .if_satisfies requirement: ::Gem::Requirement.new(">= 4") do
        super()
          .empty? and
          no_parallel_for(
            :create,
            :converge,
            :setup,
            :destroy
          )
      end

    super()
  end

  # Applies changes to the state by selecting the test workspace, updating the dependency modules, validating the root
  # module, applying the state changes, and retrieving the state output.
  #
  # @raise [::Kitchen::Terraform::Error] if one of the steps fails.
  # @return [void]
  # @yieldparam output [::String] the state output.
  def apply(&block)
    run_workspace_select_instance
    apply_run_get
    apply_run_validate
    apply_run_apply
    ::Kitchen::Terraform::Command::Output
      .run(
        duration: config_command_timeout,
        logger: logger,
        &block
      )
  end

  # Creates a Test Kitchen instance by initializing the working directory and creating a test workspace.
  #
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [void]
  def create(_state)
    create_run_init
    run_workspace_select_instance
  rescue ::Kitchen::Terraform::Error => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end

  # Destroys a Test Kitchen instance by initializing the working directory, selecting the test workspace,
  # deleting the state, selecting the default workspace, and deleting the test workspace.
  #
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [void]
  def destroy(_state)
    destroy_run_init
    run_workspace_select_instance
    destroy_run_destroy
    destroy_run_workspace_select_default
    destroy_run_workspace_delete_instance
  rescue ::Kitchen::Terraform::Error => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end

  # Verifies that the Terraform version available to the driver is supported.
  #
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @return [void]
  def verify_dependencies
    logger
      .warn(
        ::Kitchen::Terraform::ClientVersionVerifier
          .new
          .verify(
            version_output:
              ::Kitchen::Terraform::ShellOut
                .run(
                  command: "version",
                  duration: 600,
                  logger: logger
                )
          )
      )
  rescue ::Kitchen::Terraform::Error => error
    raise(
      ::Kitchen::UserError,
      error.message
    )
  end

  private

  # @api private
  def apply_run_apply
    ::Kitchen::Terraform::ShellOut
      .run(
        command:
          "apply " \
            "#{config_lock_flag} " \
            "#{config_lock_timeout_flag} " \
            "-input=false " \
            "-auto-approve=true " \
            "#{config_color_flag} " \
            "#{parallelism_flag} " \
            "-refresh=true " \
            "#{variables_flags} " \
            "#{variable_files_flags} " \
            "#{root_module_directory}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def apply_run_get
    ::Kitchen::Terraform::ShellOut
      .run(
        command: "get -update #{root_module_directory}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def apply_run_validate
    ::Kitchen::Terraform::ShellOut
      .run(
        command:
          "validate " \
            "-check-variables=true " \
            "#{config_color_flag} " \
            "#{variables_flags} " \
            "#{variable_files_flags} " \
            "#{root_module_directory}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def create_run_init
    ::Kitchen::Terraform::ShellOut
      .run(
        command:
          "init " \
            "-input=false " \
            "#{config_lock_flag} " \
            "#{config_lock_timeout_flag} " \
            "#{config_color_flag} " \
            "-upgrade " \
            "-force-copy " \
            "-backend=true " \
            "#{config_backend_configurations_flags} " \
            "-get=true " \
            "-get-plugins=true " \
            "#{plugin_directory_flag} " \
            "-verify-plugins=true " \
            "#{root_module_directory}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def destroy_run_destroy
    ::Kitchen::Terraform::ShellOut
      .run(
        command:
          "destroy " \
            "-force " \
            "#{config_lock_flag} " \
            "#{config_lock_timeout_flag} " \
            "-input=false " \
            "#{config_color_flag} " \
            "#{parallelism_flag} " \
            "-refresh=true " \
            "#{variables_flags} " \
            "#{variable_files_flags} " \
            "#{root_module_directory}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def destroy_run_init
    ::Kitchen::Terraform::ShellOut
      .run(
        command:
          "init " \
            "-input=false " \
            "#{config_lock_flag} " \
            "#{config_lock_timeout_flag} " \
            "#{config_color_flag} " \
            "-force-copy " \
            "-backend=true " \
            "#{config_backend_configurations_flags} " \
            "-get=true " \
            "-get-plugins=true " \
            "#{plugin_directory_flag} " \
            "-verify-plugins=true " \
            "#{root_module_directory}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def destroy_run_workspace_delete_instance
    ::Kitchen::Terraform::ShellOut
      .run(
        command: "workspace delete kitchen-terraform-#{instance_name}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def destroy_run_workspace_select_default
    ::Kitchen::Terraform::ShellOut
      .run(
        command: "workspace select default",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def instance_name
    @instance_name ||= instance.name
  end

  # @api private
  def parallelism_flag
    "-parallelism=#{config_parallelism}"
  end

  # @api private
  def plugin_directory_flag
    config_plugin_directory.nil? and "" or "-plugin-dir=#{::Shellwords.escape config_plugin_directory}"
  end

  # @api private
  def root_module_directory
    ::Shellwords.escape config_root_module_directory
  end

  # @api private
  def run_workspace_select_instance
    ::Kitchen::Terraform::ShellOut
      .run(
        command: "workspace select kitchen-terraform-#{instance_name}",
        duration: config_command_timeout,
        logger: logger
      )
  rescue ::Kitchen::Terraform::Error
    ::Kitchen::Terraform::ShellOut
      .run(
        command: "workspace new kitchen-terraform-#{instance_name}",
        duration: config_command_timeout,
        logger: logger
      )
  end

  # @api private
  def variable_files_flags
    config_variable_files
      .map do |path|
        "-var-file=#{::Shellwords.escape path}"
      end
      .join " "
  end

  # @api private
  def variables_flags
    config_variables
      .map do |key, value|
        "-var=#{::Shellwords.escape "#{key}=#{value}"}"
      end
      .join " "
  end
end
