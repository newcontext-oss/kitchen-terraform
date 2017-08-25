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

# Represents a Terraform command.
#
# @see https://www.terraform.io/docs/commands/index.html Terraform commands
class ::Kitchen::Terraform::Client::Command
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Try::Mixin

  def self.apply(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "apply",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  def self.destroy(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "destroy",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  def self.init(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "init",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  def self.output(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "output",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  def self.plan(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "plan",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  def self.validate(logger:, options:, timeout:, working_directory:)
    run(
      logger: logger,
      options: options,
      subcommand: "validate",
      timeout: timeout,
      working_directory: working_directory
    )
  end

  def self.version(logger:, working_directory:)
    run(
      logger: logger,
      subcommand: "version",
      working_directory: working_directory
    )
  end

  attr_reader :output

  def ==(other)
    other.is_a? self.class and to_s == other.to_s
  end

  def eq(other)
    self == other
  end

  def match(pattern)
    to_s.match pattern
  end

  def to_s
    "Output of command `#{@command}`: #{@output}"
  end

  private

  def self.run(
    logger:,
    options: ::Kitchen::Terraform::Client::Options.new,
    subcommand:,
    timeout: nil,
    working_directory:
  )
    Try ::Mixlib::ShellOut::InvalidCommandOption do
      ::Mixlib::ShellOut.new(
        "terraform #{subcommand} #{options}".strip,
        cwd: working_directory,
        live_stream: logger,
        timeout: timeout
      )
    end.to_either.bind do |shell_out|
      Try(
        ::Errno::EACCES,
        ::Errno::ENOENT,
        ::Mixlib::ShellOut::CommandTimeout,
        ::Mixlib::ShellOut::ShellCommandFailed
      ) do
        shell_out.run_command
        shell_out.error!
      end.to_either.bind do
        Right(
          new(
            command: shell_out.command,
            output: shell_out.stdout
          )
        )
      end.or do |error|
        Left(
          new(
            command: shell_out.command,
            output: error
          )
        )
      end
    end.or do |value|
      if value.kind_of? self
        Left value
      else
        Left new "Constructing client command #{subcommand}", value
      end
    end.tap do |result|
      logger.debug result.value
    end
  end

  def initialize(command:, output:)
    @command = command.to_s
    @output = output.to_s
  end
end
