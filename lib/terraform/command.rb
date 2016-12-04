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

module Terraform
  # Terraform command to be executed
  class Command
    def name
      ''
    end

    def options
      '--help'
    end

    def output
      processed_output raw_output: shell_out.stdout
    end

    def run(logger:, timeout:)
      shell_out.live_stream = logger
      shell_out.timeout = timeout
      shell_out.run_command
      shell_out.error!
    end

    def to_s
      shell_out.command
    end

    private

    attr_accessor :shell_out

    def initialize(target: '', **keyword_arguments)
      initialize_attributes(**keyword_arguments)
      self.shell_out = Mixlib::ShellOut
                       .new "terraform #{name} #{options} #{target}", returns: 0
    end

    def initialize_attributes(**_keyword_arguments) end

    def processed_output(raw_output:)
      raw_output
    end
  end
end
