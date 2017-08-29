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
require "kitchen/terraform/client"
require "mixlib/shellout"
require "kitchen/terraform/client/options"

# Represents the result of running a Terraform command.
#
# @see https://www.terraform.io/docs/commands/index.html Terraform commands
class ::Kitchen::Terraform::Client::Command
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Try::Mixin

  # Runs the apply command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/apply.html Terraform Command: apply
  def self.apply(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "apply",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # Runs the destroy command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: destroy
  def self.destroy(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "destroy",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # Runs the init command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: init
  def self.init(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "init",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # Runs the output command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: output
  def self.output(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "output",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # Runs the plan command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: plan
  def self.plan(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "plan",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # Runs the validate command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: validate
  def self.validate(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "validate",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # Runs the version command.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  # @see ::Kitchen::Terraform::DebugLogger
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: version
  def self.version(
    logger:,
    options: ::Kitchen::Terraform::Client::Options,
    timeout: nil,
    working_directory:
  )
    run(
      logger: logger,
      options: options,
      subcommand: "version",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  # @!attribute [r] output
  #   @return [::String] output generated by running.
  attr_reader :output

  # Determines equality between self and other.
  #
  # @param other [::Object]
  # @return [::TrueClass, ::FalseClass] true if self and other are equivalent commands or false
  # @see ::BasicObject#==
  def ==(other)
    self.class == other.class and to_s == other.to_s
  end

  # Determines equality between the hash keys of self and other.
  #
  # @param other [::Object]
  # @return [::TrueClass, ::FalseClass] true if self and other have equivalent hash keys or false
  # @see ::Object#eql?
  def eql?(other)
    self == other
  end

  # Searches for a match between the string representation of self and pattern.
  #
  # @param pattern [::Object] a pattern to match against.
  # @return [::MatchData, ::NilClass] if a match is found then a description of the match; else nil.
  def match(pattern)
    to_s.match pattern
  end

  # The string representation of self.
  #
  # @return [::String] self as a string.
  def to_s
    "Output of command `#{@command}`: #{@output}"
  end

  private

  # Run a command.
  #
  # @api private
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @param working_directory[::String] the path to the directory in which to run the command.
  # @return [::Dry::Monads::Either] the result of running the command.
  # @see ::Kitchen::Logger
  def self
    .run(logger:, options:, subcommand:, timeout:, working_directory:)
    Try ::Mixlib::ShellOut::InvalidCommandOption do
      ::Mixlib::ShellOut.new(
        "terraform #{subcommand} #{options}".strip,
        cwd: working_directory,
        live_stream: logger,
        timeout: timeout
      )
    end
      .to_either
      .bind do |shell_out|
        Try(
          ::Errno::EACCES,
          ::Errno::ENOENT,
          ::Mixlib::ShellOut::CommandTimeout,
          ::Mixlib::ShellOut::ShellCommandFailed
        ) do
          shell_out.run_command
          shell_out.error!
        end
          .to_either
          .bind do
            Right(
              new(
                command: shell_out.command,
                output: shell_out.stdout
              )
            )
          end
          .or do |error|
            Left(
              new(
                command: shell_out.command,
                output: error
              )
            )
          end
      end
      .tap do |result|
        logger.debug result.value
      end
  end

  # Initializes self.
  #
  # @api private
  # @param command [::Object] the command that was run.
  # @param output [::Object] the output of the command that was run.
  def initialize(command:, output:)
    @command = command
    @output = output
  end
end
