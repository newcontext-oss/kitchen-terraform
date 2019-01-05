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
require "kitchen/terraform/command_flag/backend_config"
require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/command_flag/lock_timeout"
require "kitchen/terraform/command_flag/lock"
require "kitchen/terraform/command_flag/plugin_dir"
require "kitchen/terraform/command_flag/upgrade"
require "kitchen/terraform/shell_out"

module Kitchen
  module Terraform
    module Command
      # Init is the class of objects which represent the <tt>terraform init</tt> command.
      class Init
        class << self
          # Initializes an instance by running `terraform init`.
          #
          # @param options [::Hash] the command options.
          # @option options [::Hash{::String => ::String}] :backend_config configuration for the backend.
          # @option options [true, false] :color a toggle for colored output.
          # @option options [::String] :directory the directory in which to run the command.
          # @option options [true, false] :lock a toggle for locking the state.
          # @option options [::Integer] :lock_timeout the maximum duration in seconds to wait for the lock.
          # @option options [::Integer] :plugin_dir a directory which contains customized plugins.
          # @option options [::Integer] :timeout the maximum duration in seconds to run the command.
          # @option options [true, false] :upgrade a toggle for upgrading modules and plugins.
          # @raise [::Kitchen::Terraform::Error] if the result of running the command is a failure.
          # @return [self]
          # @yieldparam init [::Kitchen::Terraform::Command::Init] an instance initialized with the output of the
          #   command.
          def run(options)
            new(options).tap do |init|
              ::Kitchen::Terraform::ShellOut.run(
                command: init,
                directory: options.fetch(:directory),
                timeout: options.fetch(:timeout),
              )
              yield init: init if block_given?
            end

            self
          end
        end

        def ==(init)
          to_s == init.to_s
        end

        def store(output:)
          @output = output

          self
        end

        def to_s
          ::Kitchen::Terraform::CommandFlag::PluginDir.new(
            command: ::Kitchen::Terraform::CommandFlag::BackendConfig.new(
              command: ::Kitchen::Terraform::CommandFlag::Upgrade.new(
                command: ::Kitchen::Terraform::CommandFlag::Color.new(
                  command: ::Kitchen::Terraform::CommandFlag::LockTimeout.new(
                    command: ::Kitchen::Terraform::CommandFlag::Lock.new(
                      command: ::String.new(
                        "terraform init " \
                        "-input=false " \
                        "-force-copy " \
                        "-backend=true " \
                        "-get=true " \
                        "-get-plugins=true " \
                        "-verify-plugins=true"
                      ),
                      lock: @lock,
                    ),
                    lock_timeout: @lock_timeout,
                  ),
                  color: @color,
                ),
                upgrade: @upgrade,
              ),
              backend_config: @backend_config,
            ),
            plugin_dir: @plugin_dir,
          ).to_s
        end

        private

        def initialize(options)
          @backend_config = options.fetch :backend_config
          @color = options.fetch :color
          @lock = options.fetch :lock
          @lock_timeout = options.fetch :lock_timeout
          @plugin_dir = options.fetch :plugin_dir
          @upgrade = options.fetch :upgrade
        end
      end
    end
  end
end
