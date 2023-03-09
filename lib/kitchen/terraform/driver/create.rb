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

require "kitchen"
require "kitchen/shell_out"
require "kitchen/terraform/command/init_factory"
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/verify_version"
require "rubygems"

module Kitchen
  module Terraform
    module Driver
      # A Test Kitchen instance is created through the following steps.
      #
      # ===== Initializing the Terraform Working Directory
      #
      # ====== Terraform >= 0.15.0
      #
      # {include:Kitchen::Terraform::Command::Init::PostZeroFifteenZero}
      #
      # ====== Terraform < 0.15.0
      #
      # {include:Kitchen::Terraform::Command::Init::PreZeroFifteenZero}
      #
      # ===== Creating or Selecting the Test Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceNew}
      #
      # {include:Kitchen::Terraform::Command::WorkspaceSelect}
      class Create
        # #call executes the action.
        #
        # @raise [Kitchen::StandardError] if a command fails.
        # @return [self]
        def call
          read_client_version
          verify_version.call version: client_version
          initialize_directory
          create_or_select_workspace

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param connection [Kitchen::Terraform::Transport::Connection] a Terraform connection.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @option config [String] :client the pathname of the Terraform client.
        # @return [Kitchen::Terraform::Driver::Create]
        def initialize(config:, connection:, logger:, version_requirement:, workspace_name:)
          self.complete_config = config.to_hash.merge upgrade_during_init: true, workspace_name: workspace_name
          self.connection = connection
          self.client_version = ::Gem::Version.new "0.0.0"
          self.logger = logger
          self.workspace_name = workspace_name
          self.workspace_new = ::Kitchen::Terraform::Command::WorkspaceNew.new config: complete_config
          self.workspace_select = ::Kitchen::Terraform::Command::WorkspaceSelect.new config: complete_config
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new(
            config: complete_config,
            logger: logger,
            version_requirement: version_requirement,
          )
          self.version = ::Kitchen::Terraform::Command::Version.new
        end

        private

        attr_accessor(
          :client_version,
          :complete_config,
          :connection,
          :logger,
          :verify_version,
          :version,
          :workspace_name,
          :workspace_new,
          :workspace_select,
        )

        def create_or_select_workspace
          logger.warn "Creating the #{workspace_name} Terraform workspace..."
          connection.execute workspace_new
          logger.warn "Finished creating the #{workspace_name} Terraform workspace."
        rescue ::Kitchen::ShellOut::ShellCommandFailed
          select_workspace
        end

        def initialize_directory
          logger.warn "Initializing the Terraform working directory..."
          connection.execute ::Kitchen::Terraform::Command::InitFactory
                               .new(version: client_version).build(config: complete_config)
          logger.warn "Finished initializing the Terraform working directory."
        end

        def read_client_version
          logger.warn "Reading the Terraform client version..."
          self.client_version = ::Gem::Version.new connection.execute(version).slice /Terraform v(\d+\.\d+\.\d+)/, 1
          logger.warn "Finished reading the Terraform client version."
        end

        def select_workspace
          logger.warn "Selecting the #{workspace_name} Terraform workspace..."
          connection.execute workspace_select
          logger.warn "Finished selecting the #{workspace_name} Terraform workspace."
        end
      end
    end
  end
end
