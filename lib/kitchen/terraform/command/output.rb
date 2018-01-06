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

require "json"
require "kitchen/terraform/command"
require "kitchen/terraform/error"
require "kitchen/terraform/shell_out"

# Behaviour to run the `terraform output` command.
module ::Kitchen::Terraform::Command::Output
  # Runs the command with JSON foramtting.
  #
  # @param duration [::Integer] the maximum duration in seconds to run the command.
  # @param logger [::Kitchen::Logger] a Test Kitchen logger to capture the output from running the command.
  # @yieldparam output [::String] the standard output of the command parsed as JSON.
  def self.run(duration:, logger:, &block)
    run_shell_out(
      duration: duration,
      logger: logger,
      &block
    )
  rescue ::JSON::ParserError => error
    handle_json_parser error: error
  rescue ::Kitchen::Terraform::Error => error
    handle_kitchen_terraform(
      error: error,
      &block
    )
  end

  private_class_method

  # @api private
  def self.handle_json_parser(error:)
    raise(
      ::Kitchen::Terraform::Error,
      "Parsing Terraform output as JSON failed: #{error.message}"
    )
  end

  # @api private
  def self.handle_kitchen_terraform(error:)
    /no\\ outputs\\ defined/.match ::Regexp.escape error.to_s or raise error
    yield output: {}
  end

  # @api private
  def self.run_shell_out(duration:, logger:)
    ::Kitchen::Terraform::ShellOut
      .run(
        command: "output -json",
        duration: duration,
        logger: logger
      ) do |standard_output:|
        yield output: ::JSON.parse(standard_output)
      end
  end
end
