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
require "mixlib/shellout"

module Terraform
  # Facilitates execution of commands in a shell
  class ShellOut
    def execute(&block)
      block ||= proc {}

      command.prepare
      run_command
      block.call shell_out.stdout
    end

    private

    attr_accessor :command, :shell_out

    def initialize(cli:, command:, logger:, timeout: ::Mixlib::ShellOut::DEFAULT_READ_TIMEOUT)
      self.command = command
      self.shell_out = ::Mixlib::ShellOut.new "#{cli} #{command}", live_stream: logger, timeout: timeout
    end

    def instance_failures
      [::Errno::EACCES, ::Errno::ENOENT, ::Mixlib::ShellOut::CommandTimeout, ::Mixlib::ShellOut::ShellCommandFailed]
    end

    def run_command
      shell_out.run_command
      shell_out.error!
    rescue *instance_failures => error
      raise ::Kitchen::StandardError, "`#{shell_out.command}` failed: '#{error.message}'"
    end
  end
end
