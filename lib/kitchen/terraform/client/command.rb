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
module ::Kitchen::Terraform::Client::Command
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Try::Mixin

  # Creates the apply command shell out.
  #
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  # @return [::Dry::Monads::Either] the result of creating the shell out.
  # @see https://www.terraform.io/docs/commands/apply.html Terraform Command: apply
  def self.apply(options:, working_directory:)
    create(
      options: options,
      subcommand: "apply",
      working_directory: working_directory
    )
  end

  #
  # Creates the destroy command shell out.
  #
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  # @return [::Dry::Monads::Either] the result of creating the shell out.
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: destroy
  def self.destroy(options:, working_directory:)
    create(
      options: options,
      subcommand: "destroy",
      working_directory: working_directory
    )
  end

  # Creates the init command shell out.
  #
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  # @return [::Dry::Monads::Either] the result of creating the shell out.
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: init
  def self.init(options:, working_directory:)
    create(
      options: options,
      subcommand: "init",
      working_directory: working_directory
    )
  end

  # Creates the output command shell out.
  #
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  # @return [::Dry::Monads::Either] the result of creating the shell out.
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: output
  def self.output(options:, working_directory:)
    create(
      options: options,
      subcommand: "output",
      working_directory: working_directory
    )
  end

  # Runs a command shell out.
  #
  # @param logger [::Kitchen::Logger, ::Terraform::DebugLogger] a logger to capture the run output of the command.
  # @param shell_out [::Mixlib::ShellOut] the shell out to run.
  # @param timeout [::Integer] the number of seconds to wait for the command to finish.
  # @return [::Dry::Monads::Either] the result of running the shell out.
  def self.run(logger:, shell_out:, timeout:)
    try_to_run(
      logger: logger,
      shell_out: shell_out,
      timeout: timeout
    )
      .bind do
        Right shell_out.stdout
      end
      .or do |error|
        Left error.to_s
      end
  end

  # Creates the validate command shell out.
  #
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  # @return [::Dry::Monads::Either] the result of creating the shell out.
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: validate
  def self.validate(options:, working_directory:)
    create(
      options: options,
      subcommand: "validate",
      working_directory: working_directory
    )
  end

  # Creates the version command shell out.
  #
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  # @return [::Dry::Monads::Either] the result of creating the shell out.
  # @see https://www.terraform.io/docs/commands/destroy.html Terraform Command: version
  def self.version(options: ::Kitchen::Terraform::Client::Options, working_directory:)
    create(
      options: options,
      subcommand: "version",
      working_directory: working_directory
    )
  end

  private_class_method

  # @api private
  # @param command [::String] the command to run through shell out.
  # @param options [::Kitchen::Terraform::Client::Options] options for the command.
  # @param working_directory[::String] the path to the directory in which to run the shell out.
  def self.create(options:, subcommand:, working_directory:)
    Try ::Mixlib::ShellOut::InvalidCommandOption do
      ::Mixlib::ShellOut.new(
        "terraform #{subcommand} #{options}".strip,
        cwd: working_directory
      )
    end
      .to_either
      .or do |error|
        Left "Failed to create `terraform #{subcommand}`: #{error}"
      end
  end

  def self.try_to_run(logger:, shell_out:, timeout:)
    Try(
      ::Errno::EACCES,
      ::Errno::ENOENT,
      ::Mixlib::ShellOut::CommandTimeout,
      ::Mixlib::ShellOut::ShellCommandFailed
    ) do
      shell_out.live_stream = logger
      shell_out.timeout = timeout
      shell_out.run_command
      shell_out.error!
    end
      .to_either
  end
end
