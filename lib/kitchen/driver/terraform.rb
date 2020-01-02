# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/version"
require "kitchen/terraform/config_attribute/backend_configurations"
require "kitchen/terraform/config_attribute/client"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/command_timeout"
require "kitchen/terraform/config_attribute/lock"
require "kitchen/terraform/config_attribute/lock_timeout"
require "kitchen/terraform/config_attribute/parallelism"
require "kitchen/terraform/config_attribute/plugin_directory"
require "kitchen/terraform/config_attribute/root_module_directory"
require "kitchen/terraform/config_attribute/variable_files"
require "kitchen/terraform/config_attribute/variables"
require "kitchen/terraform/config_attribute/verify_version"
require "kitchen/terraform/configurable"
require "kitchen/terraform/debug_logger"
require "kitchen/terraform/command_executor"
require "kitchen/terraform/version_verifier"
require "rubygems"
require "shellwords"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Driver
module ::Kitchen::Driver
end

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
#     -auto-approve \
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
# {include:Kitchen::Terraform::CommandExecutor}
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
# ==== client
#
# {include:Kitchen::Terraform::ConfigAttribute::Client}
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
# ==== verify_version
#
# {include:Kitchen::Terraform::ConfigAttribute::VerifyVersion}
#
# === Ruby Interface
#
# This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
# :reek:MissingSafeMethod { exclude: [ finalize_config! ] }
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

  no_parallel_for(
    :create,
    :converge,
    :setup,
    :destroy
  )

  include ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations

  include ::Kitchen::Terraform::ConfigAttribute::Client

  include ::Kitchen::Terraform::ConfigAttribute::Color

  include ::Kitchen::Terraform::ConfigAttribute::CommandTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Lock

  include ::Kitchen::Terraform::ConfigAttribute::LockTimeout

  include ::Kitchen::Terraform::ConfigAttribute::Parallelism

  include ::Kitchen::Terraform::ConfigAttribute::PluginDirectory

  include ::Kitchen::Terraform::ConfigAttribute::RootModuleDirectory

  include ::Kitchen::Terraform::ConfigAttribute::VariableFiles

  include ::Kitchen::Terraform::ConfigAttribute::Variables

  include ::Kitchen::Terraform::ConfigAttribute::VerifyVersion

  include ::Kitchen::Terraform::Configurable

  # Applies changes to the state by selecting the test workspace, updating the dependency modules, validating the root
  # module, and applying the state changes.
  #
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [self]
  # @yieldparam outputs [::Hash] the state output.
  def apply(&block)
    verify_version
    apply_run(&block)

    self
  rescue => error
    raise ::Kitchen::ActionFailed, error.message
  end

  # Creates a Test Kitchen instance by initializing the working directory and creating a test workspace.
  #
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [void]
  def create(_state)
    verify_version
    create_run_init
    run_workspace_select_instance
  rescue => error
    raise ::Kitchen::ActionFailed, error.message
  end

  # Destroys a Test Kitchen instance by initializing the working directory, selecting the test workspace,
  # deleting the state, selecting the default workspace, and deleting the test workspace.
  #
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [void]
  def destroy(_state)
    verify_version
    destroy_run_init
    run_workspace_select_instance
    destroy_run_destroy
    destroy_run_workspace_select_default
    destroy_run_workspace_delete_instance
  rescue => error
    raise ::Kitchen::ActionFailed, error.message
  end

  # #finalize_config! invokes the super implementation and then defines the command executor.
  #
  # @param instance [Kitchen::Instance] an associated instance.
  # @raise [Kitchen::ClientError] if the instance is nil.
  # @return [self]
  # @see Kitchen::Configurable#finalize_config!
  def finalize_config!(instance)
    super instance
    self.command_executor = ::Kitchen::Terraform::CommandExecutor.new client: config_client, logger: logger

    self
  end

  # Retrieves the Terraform variables for a Kitchen instance provided by the configuration.
  #
  # @return [self]
  # @yieldparam inputs [::Hash] the variables.
  def retrieve_variables
    yield variables: config_variables

    self
  end

  private

  attr_accessor :command_executor, :version_requirement

  def apply_run(&block)
    run_workspace_select_instance
    apply_run_get
    apply_run_validate
    apply_run_apply
    apply_run_output(&block)
  end

  # @api private
  def apply_run_apply
    command_executor.run(
      command: "apply " \
      "#{lock_flag} " \
      "#{lock_timeout_flag} " \
      "-input=false " \
      "-auto-approve=true " \
      "#{color_flag} " \
      "#{parallelism_flag} " \
      "-refresh=true " \
      "#{variables_flags} " \
      "#{variable_files_flags}",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def apply_run_get
    command_executor.run(
      command: "get -update",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  def apply_run_output(&block)
    ::Kitchen::Terraform::Command::Output.new(
      client: config_client,
      logger: ::Kitchen::Terraform::DebugLogger.new(logger),
    ).run(options: { cwd: config_root_module_directory, timeout: config_command_timeout }, &block)
  end

  # @api private
  def apply_run_validate
    command_executor.run(
      command: "validate " \
      "#{color_flag} " \
      "#{variables_flags} " \
      "#{variable_files_flags}",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def backend_configurations_flags
    config_backend_configurations.map do |key, value|
      "-backend-config=\"#{key}=#{value}\""
    end.join " "
  end

  # api private
  def color_flag
    config_color and "" or "-no-color"
  end

  # @api private
  def create_run_init
    command_executor.run(
      command: "init " \
      "-input=false " \
      "#{lock_flag} " \
      "#{lock_timeout_flag} " \
      "#{color_flag} " \
      "-upgrade " \
      "-force-copy " \
      "-backend=true " \
      "#{backend_configurations_flags} " \
      "-get=true " \
      "-get-plugins=true " \
      "#{plugin_directory_flag}" \
      "-verify-plugins=true",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def destroy_run_destroy
    command_executor.run(
      command: "destroy " \
      "-auto-approve " \
      "#{lock_flag} " \
      "#{lock_timeout_flag} " \
      "-input=false " \
      "#{color_flag} " \
      "#{parallelism_flag} " \
      "-refresh=true " \
      "#{variables_flags} " \
      "#{variable_files_flags}",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def destroy_run_init
    command_executor.run(
      command: "init " \
      "-input=false " \
      "#{lock_flag} " \
      "#{lock_timeout_flag} " \
      "#{color_flag} " \
      "-force-copy " \
      "-backend=true " \
      "#{backend_configurations_flags} " \
      "-get=true " \
      "-get-plugins=true " \
      "#{plugin_directory_flag}" \
      "-verify-plugins=true",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def destroy_run_workspace_delete_instance
    command_executor.run(
      command: "workspace delete #{workspace_name}",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def destroy_run_workspace_select_default
    command_executor.run(
      command: "workspace select default",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  def initialize(config = {})
    super
    self.version_requirement = ::Gem::Requirement.new(">= 0.11.4", "< 0.13.0")
  end

  # @api private
  def lock_flag
    "-lock=#{config_lock}"
  end

  # @api private
  def lock_timeout_flag
    "-lock-timeout=#{config_lock_timeout}s"
  end

  # @api private
  def parallelism_flag
    "-parallelism=#{config_parallelism}"
  end

  # @api private
  def plugin_directory_flag
    if config_plugin_directory
      "-plugin-dir=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit config_plugin_directory}\" "
    else
      ""
    end
  end

  # @api private
  def run_workspace_select_instance
    command_executor.run(
      command: "workspace select #{workspace_name}",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  rescue ::Kitchen::TransientFailure
    command_executor.run(
      command: "workspace new #{workspace_name}",
      options: { cwd: config_root_module_directory, timeout: config_command_timeout },
    )
  end

  # @api private
  def variable_files_flags
    config_variable_files.map do |path|
      "-var-file=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit path}\""
    end.join " "
  end

  # @api private
  def variables_flags
    config_variables.map do |key, value|
      "-var=\"#{key}=#{value}\""
    end.join " "
  end

  def verify_version
    ::Kitchen::Terraform::VersionVerifier.new(
      command: ::Kitchen::Terraform::Command::Version.new(client: config_client, logger: logger),
      logger: logger,
    ).verify(
      options: { cwd: config_root_module_directory },
      requirement: version_requirement,
      strict: config_verify_version,
    )
  end

  def workspace_name
    @workspace_name ||= "kitchen-terraform-#{::Shellwords.escape instance.name}"
  end
end
