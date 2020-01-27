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
require "shellwords"

module Kitchen
  module Terraform
    module Command
      # Init is the class of objects which run the `terraform init` command.
      class Init
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
        #   customized Terraform provider plugins} to install in place of the official Terraform provider plugins.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root
        #   Terraform module.
        # @return [Kitchen::Terraform::Command::Init]
        def initialize(config:, logger:)
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.backend_configurations = config.fetch :backend_configurations
          self.color = config.fetch :color
          self.command_timeout = config.fetch :command_timeout
          self.lock = config.fetch :lock
          self.lock_timeout = config.fetch :lock_timeout
          self.plugin_directory = config.fetch :plugin_directory
          self.root_module_directory = config.fetch :root_module_directory
        end

        # #run executes the command.
        #
        # @return [self]
        # @raise [Kitchen::TransientFailure] if the result of executing the command is a failure.
        def run
          command_executor.run(
            command: "init " \
            "-input=false " \
            "-lock=#{lock} " \
            "#{lock_timeout_flag}" \
            "#{color_flag}" \
            "-upgrade " \
            "-force-copy " \
            "-backend=true " \
            "#{backend_configurations_flags} " \
            "-get=true " \
            "-get-plugins=true " \
            "#{plugin_directory_flag}" \
            "-verify-plugins=true",
            options: { cwd: root_module_directory, timeout: command_timeout },
          )

          self
        end

        private

        attr_accessor(
          :backend_configurations,
          :color,
          :command_executor,
          :command_timeout,
          :lock,
          :lock_timeout,
          :plugin_directory,
          :root_module_directory
        )

        def backend_configurations_flags
          backend_configurations.map do |key, value|
            "-backend-config=\"#{key}=#{value}\""
          end.join " "
        end

        def color_flag
          if color
            ""
          else
            "-no-color "
          end
        end

        def lock_timeout_flag
          "-lock-timeout=#{lock_timeout}s "
        end

        def plugin_directory_flag
          if plugin_directory
            "-plugin-dir=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit plugin_directory}\" "
          else
            ""
          end
        end
      end
    end
  end
end
