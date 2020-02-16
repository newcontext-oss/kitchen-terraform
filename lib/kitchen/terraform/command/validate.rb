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
      # The root module is validated by running a command like the following example:
      #   terraform validate \
      #     [-no-color] \
      #     [-var=<variables.first>...] \
      #     [-var-file=<variable_files.first>...] \
      #     <directory>
      class Validate
        # #initialize prepares an instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger to log messages.
        # @option config [String] :client the pathname of the Terraform client.
        # @option config [Boolean] :color a toggle of colored output from the Terraform client.
        # @option config [Integer] :command_timeout the the number of seconds to wait for the command to finish running.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root
        #   Terraform module.
        # @option config [Array<String>] :variable_files a list of pathnames of Terraform variable files to evaluate.
        # @option config [Hash{String=>String}] :variables a mapping of Terraform variables to evaluate.
        # @return [Kitchen::Terraform::Command::Validate]
        def initialize(config:, logger:)
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.color = config.fetch :color
          self.options = { cwd: config.fetch(:root_module_directory), timeout: config.fetch(:command_timeout) }
          self.variable_files = config.fetch :variable_files
          self.variables = config.fetch :variables
        end

        # #run executes the command.
        #
        # @return [self]
        # @raise [Kitchen::TransientFailure] if the result of executing the command is a failure.
        def run
          command_executor.run(
            command: "validate " \
            "#{color_flag} " \
            "#{variables_flags} " \
            "#{variable_files_flags}",
            options: options,
          )

          self
        end

        private

        attr_accessor(
          :color,
          :command_executor,
          :options,
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
