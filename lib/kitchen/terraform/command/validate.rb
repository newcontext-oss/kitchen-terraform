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
require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/command_flag/variable_files"
require "kitchen/terraform/command_flag/variables"
require "kitchen/terraform/shell_out_nu"

module Kitchen
  module Terraform
    module Command
      # Validate is the class of objects which represent the <tt>terraform validate</tt> command.
      class Validate
        class << self
          # Initializes an instance by running `terraform validate`.
          #
          # @param options [::Hash] the command options.
          # @option options [true, false] :color a toggle for colored output.
          # @option options [::String] :directory the directory in which to run the command.
          # @option options [::Integer] :timeout the maximum duration in seconds to run the command.
          # @option options [::Array<::String>] :variable_files files containing variables for the configuration.
          # @option options [::Hash{::String => ::String}] :variables variables for the configuration.
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [self]
          # @yieldparam validate [::Kitchen::Terraform::Command::Validate] an instance initialized with the output of
          #   the command.
          def run(options)
            new(
              color: options.fetch(:color),
              variable_files: options.fetch(:variable_files),
              variables: options.fetch(:variables),
            ).tap do |validate|
              ::Kitchen::Terraform::ShellOutNu.run(
                command: validate,
                directory: options.fetch(:directory),
                timeout: options.fetch(:timeout),
              )
              yield validate: validate
            end

            self
          end
        end

        def ==(validate)
          to_s == validate.to_s
        end

        def store(output:)
          @output = String output

          self
        end

        def to_s
          ::Kitchen::Terraform::CommandFlag::Variables.new(
            command: ::Kitchen::Terraform::CommandFlag::VariableFiles.new(
              command: ::Kitchen::Terraform::CommandFlag::Color.new(
                command: ::String.new("terraform validate -check-variables=true"),
                color: @color,
              ),
              variable_files: @variable_files,
            ),
            variables: @variables,
          ).to_s
        end

        private

        def initialize(color:, variable_files:, variables:)
          @color = color
          @variable_files = variable_files
          @variables = variables
        end
      end
    end
  end
end
