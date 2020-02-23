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

require "kitchen/terraform/command_executor"
require "kitchen/terraform/command_flag/backend_config"
require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/command_flag/lock_timeout"
require "kitchen/terraform/command_flag/plugin_dir"
require "kitchen/terraform/command_flag/upgrade"

module Kitchen
  module Terraform
    module Command
      # The working directory is initialized by running a command like the following example:
      #   terraform init \
      #     -input=false \
      #     -lock=<lock> \
      #     -lock-timeout=<lock_timeout>s \
      #     [-no-color] \
      #     [-upgrade] \
      #     -force-copy \
      #     -backend=true \
      #     [-backend-config=<backend_configurations[0]> ...] \
      #     -get=true \
      #     -get-plugins=true \
      #     [-plugin-dir=<plugin_directory>] \
      #     -verify-plugins=true \
      #     <root_module_directory>
      class Init
        # #initialize prepares an instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @option config [Hash{String=>String}] :backend_configurations Terraform backend configuration arguments to
        #   complete a partial backend configuration.
        # @option config [String] :client the pathname of the Terraform client.
        # @option config [Boolean] :color a toggle of colored output from the Terraform client.
        # @option config [Integer] :command_timeout the the number of seconds to wait for the command to finish running.
        # @option config [Boolean] :lock a toggle of locking for the Terraform state file.
        # @option config [Integer] :lock_timeout the number of seconds that the Terraform client will wait for a lock
        #   on the state to be obtained during operations.
        # @option config [String] :plugin_directory the pathname of the directory which contains
        #   customized Terraform provider plugins to install in place of the official Terraform provider plugins.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root
        #   Terraform module.
        # @option config [Boolean] :upgrade_during_init a toggle for upgrading modules and plugins.
        # @return [Kitchen::Terraform::Command::Init]
        def initialize(config:, logger:)
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.backend_config = ::Kitchen::Terraform::CommandFlag::BackendConfig.new arguments: config.fetch(
            :backend_configurations
          )
          self.color = ::Kitchen::Terraform::CommandFlag::Color.new enabled: config.fetch(:color)
          self.lock = config.fetch :lock
          self.lock_timeout = ::Kitchen::Terraform::CommandFlag::LockTimeout.new duration: config.fetch(:lock_timeout)
          self.logger = logger
          self.options = { cwd: config.fetch(:root_module_directory), timeout: config.fetch(:command_timeout) }
          self.plugin_dir = ::Kitchen::Terraform::CommandFlag::PluginDir.new pathname: config.fetch(
            :plugin_directory
          )
          self.upgrade = ::Kitchen::Terraform::CommandFlag::Upgrade.new enabled: config.fetch(:upgrade_during_init)
        end

        # #run executes the command.
        #
        # @return [self]
        # @raise [Kitchen::TransientFailure] if the result of executing the command is a failure.
        def run
          logger.warn "Initializing the Terraform working directory..."
          command_executor.run(
            command: "init " \
            "-input=false " \
            "-lock=#{lock} " \
            "#{lock_timeout} " \
            "#{color} " \
            "#{upgrade} " \
            "-force-copy " \
            "-backend=true " \
            "#{backend_config} " \
            "-get=true " \
            "-get-plugins=true " \
            "#{plugin_dir} " \
            "-verify-plugins=true",
            options: options,
          ) do |standard_output:|
            logger.warn "Finished initializing the Terraform working directory."
          end

          self
        end

        private

        attr_accessor(
          :backend_config,
          :color,
          :command_executor,
          :lock,
          :lock_timeout,
          :logger,
          :options,
          :plugin_dir,
          :upgrade,
        )
      end
    end
  end
end
