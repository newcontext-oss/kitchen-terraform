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

require "kitchen/terraform/client"
require "kitchen/terraform/client/process_options"
require "mixlib/shellout"

::Kitchen::Terraform::Client::ExecuteCommand = lambda do |command:, config:, logger:, options: {}, target: ""|
  catch :success do
    ::Kitchen::Terraform::Client::ProcessOptions.call unprocessed_options: options
  end.tap do |processed_options|
    ::Mixlib::ShellOut.new(
      config.fetch(:cli), command, *processed_options, target,
      live_stream: logger, timeout: config.fetch(:apply_timeout)
    ).tap do |shell_out|
      begin
        shell_out.run_command
        shell_out.error!
        throw :success, shell_out.stdout
      rescue ::Errno::EACCES, ::Errno::ENOENT, ::Mixlib::ShellOut::CommandTimeout,
             ::Mixlib::ShellOut::ShellCommandFailed => error
        throw :failure, "`#{shell_out.command}` failed: '#{error.message}'"
      end
    end
  end
end
