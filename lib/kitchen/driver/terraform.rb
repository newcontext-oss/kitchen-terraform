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
require "kitchen/terraform/output_parser"

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
# Terraform commands are run by shelling out and using the
# {https://www.terraform.io/docs/commands/index.html command-line interface}, which is assumed to be present in the
# {https://en.wikipedia.org/wiki/PATH_(variable) PATH} of the user. The shell out environment includes the
# TF_IN_AUTOMATION environment variable as specified by the
# {https://www.terraform.io/guides/running-terraform-in-automation.html#controlling-terraform-output-in-automation Running Terraform in Automation guide}.
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
  def apply
    run_workspace_select_instance
    apply_run_get
    apply_run_validate
    apply_run_apply

    @output_parser
      .output=(
        run_command(
          "terraform output -json",
          environment:
            {
              "LC_ALL" => nil,
              "TF_IN_AUTOMATION" => true
            },
          timeout: config_command_timeout
        )
      )

    @output_parser
      .parse do |parsed_output:|
        yield output: parsed_output
      end
  rescue ::Kitchen::ShellOut::ShellCommandFailed => shell_command_failed
    if /no\\ outputs\\ defined/.match(::Regexp.escape(shell_command_failed.message))
      yield output: {}
    else
      raise(
        ::Kitchen::Terraform::Error,
        shell_command_failed.message
      )
    end
  end

  # Creates a Test Kitchen instance by initializing the working directory and creating a test workspace.
  #
  # @param _state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [void]
  def create(_state)
    create_run_init
    run_workspace_select_instance
  rescue ::Kitchen::ShellOut::ShellCommandFailed => error
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
  rescue ::Kitchen::ShellOut::ShellCommandFailed => error
    raise(
      ::Kitchen::ActionFailed,
      error.message
    )
  end

  # Verifies that the Terraform version available to the driver is supported.
  #
  # @note This method is invoked before the configuration is validated so it must not depend on any configuration
  #       attributes.
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @return [void]
  def verify_dependencies
    logger
      .warn(
        ::Kitchen::Terraform::ClientVersionVerifier
          .new
          .verify(
            version_output:
              run_command(
                "terraform version",
                environment:
                  {
                    "LC_ALL" => nil,
                    "TF_IN_AUTOMATION" => true
                  },
                timeout: 600
              )
          )
      )
  rescue ::Kitchen::ShellOut::ShellCommandFailed, ::Kitchen::Terraform::Error => error
    raise(
      ::Kitchen::UserError,
      error.message
    )
  end

  private

  # @api private
  def apply_run_apply
    run_command(
      "terraform apply " \
        "#{config_lock_flag} " \
        "#{config_lock_timeout_flag} " \
        "-input=false " \
        "-auto-approve=true " \
        "#{config_color_flag} " \
        "#{config_parallelism_flag} " \
        "-refresh=true " \
        "#{config_variables_flags} " \
        "#{config_variable_files_flags} " \
        "#{config_root_module_directory}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def apply_run_get
    run_command(
      "terraform get -update #{config_root_module_directory}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def apply_run_validate
    run_command(
      "terraform validate " \
        "-check-variables=true " \
        "#{config_color_flag} " \
        "#{config_variables_flags} " \
        "#{config_variable_files_flags} " \
        "#{config_root_module_directory}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def create_run_init
    run_command(
      "terraform init " \
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
        "#{config_plugin_directory_flag} " \
        "-verify-plugins=true " \
        "#{config_root_module_directory}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def destroy_run_destroy
    run_command(
      "terraform destroy " \
        "-force " \
        "#{config_lock_flag} " \
        "#{config_lock_timeout_flag} " \
        "-input=false " \
        "#{config_color_flag} " \
        "#{config_parallelism_flag} " \
        "-refresh=true " \
        "#{config_variables_flags} " \
        "#{config_variable_files_flags} " \
        "#{config_root_module_directory}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def destroy_run_init
    run_command(
      "terraform init " \
        "-input=false " \
        "#{config_lock_flag} " \
        "#{config_lock_timeout_flag} " \
        "#{config_color_flag} " \
        "-force-copy " \
        "-backend=true " \
        "#{config_backend_configurations_flags} " \
        "-get=true " \
        "-get-plugins=true " \
        "#{config_plugin_directory_flag} " \
        "-verify-plugins=true " \
        "#{config_root_module_directory}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def destroy_run_workspace_delete_instance
    run_command(
      "terraform workspace delete kitchen-terraform-#{instance_name}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def destroy_run_workspace_select_default
    run_command(
      "terraform workspace select default",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end

  # @api private
  def initialize(config = {})
    super config
    @output_parser = ::Kitchen::Terraform::OutputParser.new
  end

  # @api private
  def instance_name
    @instance_name ||= instance.name
  end

  # @api private
  def run_workspace_select_instance
    run_command(
      "terraform workspace select kitchen-terraform-#{instance_name}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  rescue ::Kitchen::ShellOut::ShellCommandFailed
    run_command(
      "terraform workspace new kitchen-terraform-#{instance_name}",
      environment:
        {
          "LC_ALL" => nil,
          "TF_IN_AUTOMATION" => true
        },
      timeout: config_command_timeout
    )
  end
end
