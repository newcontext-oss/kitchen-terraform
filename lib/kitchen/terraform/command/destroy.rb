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
      # Destroy is the class of objects which run the `terraform destroy` command.
      class Destroy
        # #initialize prepares an instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @option config [String] :client the pathname of the Terraform client.
        # @option config [Boolean] :color a toggle of colored output from the Terraform client.
        # @option config [Integer] :command_timeout the the number of seconds to wait for the command to finish running.
        # @option config [Boolean] :lock a toggle of locking for the Terraform state file.
        # @option config [Integer] :lock_timeout the number of seconds that the Terraform client will wait for a lock
        #   on the state to be obtained during operations.
        #   customized Terraform provider plugins} to install in place of the official Terraform provider plugins.
        # @option config [Integer] :parallelism the number of concurrent operations to use while Terraform walks the
        #   resource graph.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root
        #   Terraform module.
        # @option config [Array<String>] :variable_files a list of pathnames of Terraform variable files to evaluate.
        # @option config [Hash{String=>String}] :variables a mapping of Terraform variables to evaluate.
        # @return [Kitchen::Terraform::Command::Destroy]
        def initialize(config:, logger:)
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.color = config.fetch :color
          self.command_timeout = config.fetch :command_timeout
          self.lock = config.fetch :lock
          self.lock_timeout = config.fetch :lock_timeout
          self.parallelism = config.fetch :parallelism
          self.root_module_directory = config.fetch :root_module_directory
          self.variable_files = config.fetch :variable_files
          self.variables = config.fetch :variables
        end

        # #run executes the command.
        #
        # @return [self]
        # @raise [Kitchen::TransientFailure] if the result of executing the command is a failure.
        def run
          command_executor.run(
            command: "destroy " \
            "-auto-approve " \
            "-lock=#{lock} " \
            "#{lock_timeout_flag} " \
            "-input=false " \
            "#{color_flag} " \
            "-parallelism=#{parallelism} " \
            "-refresh=true " \
            "#{variables_flags} " \
            "#{variable_files_flags}",
            options: { cwd: root_module_directory, timeout: command_timeout },
          )

          self
        end

        private

        attr_accessor(
          :color,
          :command_executor,
          :command_timeout,
          :lock,
          :lock_timeout,
          :parallelism,
          :root_module_directory,
          :variable_files,
          :variables,
        )

        def color_flag
          if color
            ""
          else
            "-no-color"
          end
        end

        def lock_timeout_flag
          "-lock-timeout=#{lock_timeout}s"
        end

        def variable_files_flags
          variable_files.map do |path|
            "-var-file=\"#{::Shellwords.shelljoin ::Shellwords.shellsplit path}\""
          end.join " "
        end

        def variables_flags
          variables.map do |key, value|
            "-var=\"#{key}=#{value}\""
          end.join " "
        end
      end
    end
  end
end
