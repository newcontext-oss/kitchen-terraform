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

module Kitchen
  # This namespace is defined by {https://www.rubydoc.info/gems/test-kitchen/Kitchen/Driver Kitchen}.
  module Driver
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
    # A Kitchen instance is created. This instance corresponds to a Terraform state.
    #
    # ===== Describing the Command
    #
    #   kitchen help create
    #
    # ===== Creating a Kitchen Instance
    #
    #   kitchen create default-ubuntu
    #
    # ====== Initializing the Terraform Working Directory
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
    # ====== Creating a Test Terraform Workspace
    #
    #   terraform workspace <new|select> kitchen-terraform-<instance>
    #
    # ==== kitchen destroy
    #
    # A Kitchen instance is destroyed. This instance corresponds to a Terraform state.
    #
    # ===== Describing the Command
    #
    #   kitchen help destroy
    #
    # ===== Destroying a Kitchen Instance
    #
    #   kitchen destroy default-ubuntu
    #
    # ====== Initializing the Terraform Working Directory
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
    # ====== Selecting the Test Terraform Workspace
    #
    #   terraform workspace <select|new> kitchen-terraform-<instance>
    #
    # ====== Destroying the Terraform State
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
    # ====== Selecting the Default Terraform Workspace
    #
    #   terraform workspace select default
    #
    # ====== Deleting the Test Terraform Workspace
    #
    #   terraform workspace delete kitchen-terraform-<instance>
    #
    # ==== kitchen doctor
    #
    # Checks the test system and the Kitchen configuration for common errors.
    #
    # ===== Describing the Command
    #
    #   kitchen help doctor
    #
    # ===== Checking for Errors
    #
    #   kitchen doctor
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
    # @version 2
    class Terraform < ::Kitchen::Driver::Base
      kitchen_driver_api_version 2

      no_parallel_for(
        :create,
        :converge,
        :setup,
        :destroy
      )

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

      # Applies changes to the state by selecting the test workspace, updating the dependency modules, validating the
      # root module, applying the state changes, and retrieving the state output.
      #
      # @raise [::Kitchen::Terraform::Error] if one of the steps fails.
      # @return [void]
      # @yieldparam output [::String] the state output.
      def apply(&block)
        run_workspace_select_instance
        apply_run_get
        apply_run_validate
        apply_run_apply
        ::Kitchen::Terraform::Command::Output.run(
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
          &block
        )
      end

      # Creates a Test Kitchen instance by initializing the working directory and creating a test workspace.
      #
      # @param _state [::Hash] the mutable instance and driver state.
      # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def create(_state)
        execute_action do
          create_run_init
          run_workspace_select_instance
        end
      end

      # Destroys a Test Kitchen instance by initializing the working directory, selecting the test workspace,
      # deleting the state, selecting the default workspace, and deleting the test workspace.
      #
      # @param _state [::Hash] the mutable instance and driver state.
      # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def destroy(_state)
        execute_action do
          destroy_run_init
          run_workspace_select_instance
          destroy_run_destroy
          destroy_run_workspace_delete_instance
        end
      end

      # Verifies that the Terraform version available to the driver is supported.
      #
      # @raise [::Kitchen::UserError] if the version is not supported.
      # @return [void]
      def verify_dependencies
        logger.warn ::Kitchen::Terraform::ClientVersionVerifier.new.verify(
          version_output: ::Kitchen::Terraform::ShellOut.run(
            command: "version",
            options: {
              cwd: ::Dir.pwd,
              live_stream: logger,
              timeout: 600,
            },
          ),
        )
      rescue ::Kitchen::Terraform::Error => error
        raise ::Kitchen::UserError, error.message
      end

      private

      def apply_run_apply
        ::Kitchen::Terraform::ShellOut.run(
          command: "apply " \
          "#{config_lock_flag} " \
          "#{config_lock_timeout_flag} " \
          "-input=false " \
          "-auto-approve=true " \
          "#{config_color_flag} " \
          "#{config_parallelism_flag} " \
          "-refresh=true " \
          "#{config_variables_flags} " \
          "#{config_variable_files_flags}",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def apply_run_get
        ::Kitchen::Terraform::ShellOut.run(
          command: "get -update",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def apply_run_validate
        ::Kitchen::Terraform::ShellOut.run(
          command: "validate " \
          "-check-variables=true " \
          "#{config_color_flag} " \
          "#{config_variables_flags} " \
          "#{config_variable_files_flags}",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def create_run_init
        ::Kitchen::Terraform::ShellOut.run(
          command: "init " \
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
          "-verify-plugins=true",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def destroy_run_destroy
        ::Kitchen::Terraform::ShellOut.run(
          command: "destroy " \
          "-auto-approve " \
          "#{config_lock_flag} " \
          "#{config_lock_timeout_flag} " \
          "-input=false " \
          "#{config_color_flag} " \
          "#{config_parallelism_flag} " \
          "-refresh=true " \
          "#{config_variables_flags} " \
          "#{config_variable_files_flags}",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def destroy_run_init
        ::Kitchen::Terraform::ShellOut.run(
          command: "init " \
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
          "-verify-plugins=true",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def destroy_run_workspace_delete_instance
        ::Kitchen::Terraform::ShellOut.run(
          command: "workspace select default",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
        ::Kitchen::Terraform::ShellOut.run(
          command: "workspace delete #{workspace_name}",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def run_workspace_select_instance
        ::Kitchen::Terraform::ShellOut.run(
          command: "workspace select #{workspace_name}",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      rescue ::Kitchen::Terraform::Error
        ::Kitchen::Terraform::ShellOut.run(
          command: "workspace new #{workspace_name}",
          options: {
            cwd: config_root_module_directory_path,
            live_stream: logger,
            timeout: config_command_timeout,
          },
        )
      end

      def workspace_name
        @workspace_name ||= "kitchen-terraform-#{::Shellwords.escape instance.name}"
      end
    end
  end
end
