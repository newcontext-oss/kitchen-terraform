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

require 'kitchen'
require 'mixlib/shellout'

module Terraform
  # Interface to the Terraform command line client
  class Command
    def self.execute(**keyword_arguments, &block)
      new(**keyword_arguments).execute(&block)
    end

    def execute
      shell_out.run_command
      shell_out.error!
      yield shell_out.stdout if block_given?
    rescue Errno::EACCES, Errno::ENOENT => error
      command_error error: error, type: Kitchen::InstanceFailure
    rescue Mixlib::ShellOut::CommandTimeout,
           Mixlib::ShellOut::ShellCommandFailed => error
      command_error error: error, type: Kitchen::TransientFailure
    end

    def name
      ''
    end

    def options
      '--help'
    end

    private

    attr_accessor :shell_out

    def command_error(error:, type:)
      raise type, %(`#{shell_out.command}` failed: "#{error}")
    end

    def initialize(
      logger:, target: '', timeout: Mixlib::ShellOut::DEFAULT_READ_TIMEOUT,
      **keyword_arguments
    )
      initialize_attributes(**keyword_arguments)
      self.shell_out = Mixlib::ShellOut
                       .new "terraform #{name} #{options} #{target}",
                            live_stream: logger, returns: 0, timeout: timeout
    end

    def initialize_attributes(**_keyword_arguments)
    end
  end
end
