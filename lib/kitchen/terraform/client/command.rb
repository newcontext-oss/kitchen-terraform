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

  def self.apply(logger:, options:, target:, timeout:, working_directory:, &block)
    new(
      logger: logger,
      options: options,
      subcommand: "apply",
      target: target,
      timeout: timeout,
      working_directory: working_directory
    ).run &block
  end

  def self.init(logger:, options:, target:, timeout:, working_directory:, &block)
    new(
      logger: logger,
      options: options,
      subcommand: "init",
      target: target,
      timeout: timeout,
      working_directory: working_directory
    ).run &block
  end

  def self.output(logger:, options:, timeout:, working_directory:, &block)
    new(
      logger: logger,
      options: options,
      subcommand: "output",
      target: "",
      timeout: timeout,
      working_directory: working_directory
    ).run &block
  end

  def self.plan(logger:, options:, target:, timeout:, working_directory:, &block)
    new(
      logger: logger,
      options: options,
      subcommand: "plan",
      target: target,
      timeout: timeout,
      working_directory: working_directory
    ).run &block
  end

  def self.validate(logger:, target:, timeout:, working_directory:, &block)
    new(
      logger: logger,
      options: [],
      subcommand: "validate",
      target: target,
      timeout: timeout,
      working_directory: working_directory
    ).run &block
  end

  def self.version(logger:, working_directory:, &block)
    new(
      logger: logger,
      options: [],
      target: "",
      timeout: nil,
      subcommand: "version",
      working_directory: working_directory
    ).run &block
  end

  include ::Dry::Monads::Either::Mixin

  include ::Dry::Monads::Try::Mixin

  def run
    Try ::Errno::EACCES, ::Errno::ENOENT, ::Mixlib::ShellOut::CommandTimeout do
      shell_out.run_command
    end.bind do
      Try ::Mixlib::ShellOut::ShellCommandFailed do
        shell_out.error!
      end
    end.to_either.bind do
      logger.debug "Command succeeded: #{summary}"
      yield shell_out.stdout
    end.or do |error|
      Left "Command failed: #{summary}\n#{error}"
    end
  end

  private

  attr_accessor :logger, :shell_out, :summary

  def initialize(logger:, options:, subcommand:, target:, timeout:, working_directory:)
    self.logger = logger
    self.shell_out = ::Mixlib::ShellOut.new(
      [
        "terraform",
        subcommand,
        *options.map(&:to_s),
        target
      ].join(" ").strip,
      cwd: working_directory,
      live_stream: logger,
      timeout: timeout
    )
    self.summary = "`#{shell_out.command}`"
  end
end
