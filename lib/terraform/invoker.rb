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

require_relative 'shell_out'

module Terraform
  # Executes commands
  class Invoker
    def execute(
      command:, timeout: ::Terraform::ShellOut.default_timeout, &block
    )
      command.if_requirements_not_met do |reason|
        return logger.debug "#{command} is disabled due to #{reason}"
      end

      command.prepare
      ::Terraform::ShellOut
        .new(command: command, logger: logger, timeout: timeout).execute(&block)
    end

    private

    attr_accessor :logger

    def initialize(logger:)
      self.logger = logger
    end
  end
end
