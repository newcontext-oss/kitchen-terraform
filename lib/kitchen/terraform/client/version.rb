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

require "kitchen/terraform/client/execute_command"
require "mixlib/shellout"

# Command to retrieve the version
::Kitchen::Terraform::Client::Version = lambda do |cli:, logger:, timeout:, &block|
  ::Mixlib::ShellOut.new(cli, "version", live_stream: logger, timeout: timeout).tap do |shell_out|
    ::Kitchen::Terraform::Client::ExecuteCommand.call shell_out: shell_out
    block.call version: Float(shell_out.stdout.slice(/v(\d+\.\d+)/, 1))
  end
end
