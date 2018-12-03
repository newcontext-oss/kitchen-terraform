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
require "kitchen"
require "kitchen/terraform/command"
require "kitchen/terraform/error"
require "kitchen/terraform/shell_out"

# Behaviour to run the `terraform output` command.
module ::Kitchen::Terraform::Command::Output
  class << self
    # Runs the command with JSON foramtting.
    #
    # @option options [::String] :cwd the directory in which to run the command.
    # @option options [::Kitchen::Logger] :live_stream a Test Kitchen logger to capture the output from running the
    #   command.
    # @option options [::Integer] :timeout the maximum duration in seconds to run the command.
    # @param options [::Hash] options which adjust the execution of the command.
    # @yieldparam output [::String] the standard output of the command parsed as JSON.
    def run(options:, &block)
      run_shell_out(
        options: options,
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

    private

    # @api private
    def handle_json_parser(error:)
      raise(
        ::Kitchen::Terraform::Error,
        "Parsing Terraform output as JSON failed: #{error.message}"
      )
    end

    # @api private
    def handle_kitchen_terraform(error:)
      /no\\ outputs\\ defined/.match ::Regexp.escape error.to_s or raise error
      yield outputs: {}
    end

    # @api private
    def run_shell_out(options:)
      ::Kitchen::Terraform::ShellOut
        .run(
          command: "output -json",
          options: options,
        ) do |standard_output:|
        yield outputs: ::JSON.parse(standard_output)
      end
    end
  end
end
