# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "kitchen/terraform/command_flag/backend_config"
require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/command_flag/lock_timeout"
require "kitchen/terraform/command_flag/plugin_dir"
require "kitchen/terraform/command_flag/upgrade"

module Kitchen
  module Terraform
    module Command
      module Init
        # The working directory is initialized by running a command like the following example:
        #   terraform init \
        #     -backend=true \
        #     [-backend-config=<backend_configurations[0]> ...] \
        #     -force-copy \
        #     -get=true \
        #     -input=false \
        #     [-no-color] \
        #     [-plugin-dir=<plugin_directory>] \
        #     [-upgrade=true] \
        #     <root_module_directory>
        class PostZeroFifteenZero
          # #initialize prepares a new instance of the class.
          #
          # @param config [Hash] the configuration of the driver.
          # @option config [Hash{String=>String}] :backend_configurations Terraform backend configuration arguments to
          #   complete a partial backend configuration.
          # @option config [Boolean] :color a toggle of colored output from the Terraform client.
          #   on the state to be obtained during operations.
          # @option config [String] :plugin_directory the pathname of the directory which contains
          #   customized Terraform provider plugins to install in place of the official Terraform provider plugins.
          # @option config [Boolean] :upgrade_during_init a toggle for upgrading modules and plugins.
          # @return [Kitchen::Terraform::Command::Init::PostZeroFifteenZero]
          def initialize(config:)
            self.backend_config = ::Kitchen::Terraform::CommandFlag::BackendConfig.new arguments: config.fetch(
              :backend_configurations
            )
            self.color = ::Kitchen::Terraform::CommandFlag::Color.new enabled: config.fetch(:color)
            self.plugin_dir = ::Kitchen::Terraform::CommandFlag::PluginDir.new pathname: config.fetch(
              :plugin_directory
            )
            self.upgrade = ::Kitchen::Terraform::CommandFlag::Upgrade.new enabled: config.fetch(:upgrade_during_init)
          end

          # @return [String] the command with flags.
          def to_s
            "init " \
            "-backend=true " \
            "#{backend_config} " \
            "-force-copy=true " \
            "-get=true " \
            "-input=false " \
            "#{color} " \
            "#{plugin_dir} " \
            "#{upgrade}"
          end

          private

          attr_accessor(
            :backend_config,
            :color,
            :lock,
            :lock_timeout,
            :options,
            :plugin_dir,
            :upgrade,
          )
        end
      end
    end
  end
end
