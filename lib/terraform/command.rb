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

require 'mixlib/shellout'
require 'pathname'
require_relative 'command_options'
require_relative 'user_error'

module Terraform
  # Common logic for Mixlib::ShellOut Terraform commands
  module Command
    attr_reader :name, :options, :target

    def execute
      shell_out.run_command
      shell_out.error!
      yield shell_out.stdout if block_given?
    rescue Errno::EACCES, Errno::ENOENT, Mixlib::ShellOut::CommandTimeout,
           Mixlib::ShellOut::ShellCommandFailed
      raise UserError
    end

    def to_s
      CommandOptions.new options do |command_options|
        return "terraform #{name} #{command_options} #{target}"
      end
    end

    private

    attr_accessor :shell_out

    attr_writer :name, :options, :target

    def initialize(
      logger:, timeout: Mixlib::ShellOut::DEFAULT_READ_TIMEOUT,
      **keyword_arguments
    )
      initialize_attributes(**keyword_arguments)
      self.shell_out = Mixlib::ShellOut.new to_s, returns: 0, timeout: timeout,
                                                  live_stream: logger
      yield self if block_given?
    end
  end
end
