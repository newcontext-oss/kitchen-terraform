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
require "kitchen/terraform/command/apply"
require "kitchen/terraform/command/get"
require "kitchen/terraform/command/output"
require "kitchen/terraform/command/validate_factory"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/debug_logger"
require "kitchen/terraform/outputs_manager"
require "kitchen/terraform/outputs_parser"
require "kitchen/terraform/outputs_reader"
require "kitchen/terraform/variables_manager"
require "kitchen/terraform/verify_version"
require "kitchen/terraform/version"
require "rubygems"

module Kitchen
  module Terraform
    module Provisioner
      # A Test Kitchen instance is converged through the following steps.
      #
      # ===== Selecting the Test Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceSelect}
      #
      # ===== Updating the Terraform Dependency Modules
      #
      # {include:Kitchen::Terraform::Command::Get}
      #
      # ===== Validating the Terraform Root Module
      #
      # ====== Terraform >= 0.15.0
      #
      # {include:Kitchen::Terraform::Command::Validate::PostZeroFifteenZero}
      #
      # ====== Terraform < 0.15.0
      #
      # {include:Kitchen::Terraform::Command::Validate::PreZeroFifteenZero}
      #
      # ===== Applying the Terraform State Changes
      #
      # {include:Kitchen::Terraform::Command::Apply}
      #
      # ===== Retrieving the Terraform Output
      #
      # {include:Kitchen::Terraform::Command::Output}
      class Converge
        # #call executes the action.
        #
        # @param state [Hash] the Kitchen instance state.
        # @raise [Kitchen::TransientFailure] if a command fails.
        # @return [self]
        def call(state:)
          read_client_version
          verify_version.call version: client_version
          execute_workflow
          save_variables_and_outputs state: state

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param connection [Kitchen::Terraform::Transport::Connection] a Terraform connection.
        # @param debug_connection [Kitchen::Terraform::Transport::Connection] a Terraform connection that logs at the
        #        debug level.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @return [Kitchen::Terraform::Driver::Converge]
        def initialize(config:, connection:, debug_connection:, logger:, version_requirement:, workspace_name:)
          self.complete_config = config.to_hash.merge workspace_name: workspace_name
          self.client_version = ::Gem::Version.new "0.0.0"
          self.connection = connection
          self.debug_connection = debug_connection
          self.logger = logger
          self.workspace_name = workspace_name
          initialize_commands
          initialize_outputs_handlers
          self.variables = complete_config.fetch :variables
          self.variables_manager = ::Kitchen::Terraform::VariablesManager.new
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new(
            config: complete_config,
            logger: logger,
            version_requirement: version_requirement,
          )
        end

        private

        attr_accessor(
          :client_version,
          :complete_config,
          :connection,
          :debug_connection,
          :get,
          :logger,
          :output,
          :outputs_manager,
          :outputs_parser,
          :outputs_reader,
          :variables_manager,
          :variables,
          :verify_version,
          :version,
          :workspace_name,
          :workspace_select,
        )

        def build_infrastructure
          logger.warn "Building the infrastructure based on the Terraform configuration..."
          connection.execute ::Kitchen::Terraform::Command::Apply.new config: complete_config
          logger.warn "Finished building the infrastructure based on the Terraform configuration."
        end

        def download_modules
          logger.warn "Downloading the modules needed for the Terraform configuration..."
          connection.execute get
          logger.warn "Finished downloading the modules needed for the Terraform configuration."
        end

        def execute_workflow
          select_workspace
          download_modules
          validate_files
          build_infrastructure
        end

        def initialize_commands
          self.get = ::Kitchen::Terraform::Command::Get.new
          self.output = ::Kitchen::Terraform::Command::Output.new
          self.workspace_select = ::Kitchen::Terraform::Command::WorkspaceSelect.new config: complete_config
          self.version = ::Kitchen::Terraform::Command::Version.new
        end

        def initialize_outputs_handlers
          self.outputs_manager = ::Kitchen::Terraform::OutputsManager.new
          self.outputs_parser = ::Kitchen::Terraform::OutputsParser.new
          self.outputs_reader = ::Kitchen::Terraform::OutputsReader.new connection: debug_connection
        end

        def parse_outputs(json_outputs:)
          logger.warn "Parsing the Terraform output variables as JSON..."
          outputs_parser.parse json_outputs: json_outputs do |parsed_outputs:|
            logger.warn "Finished parsing the Terraform output variables as JSON."

            yield parsed_outputs: parsed_outputs
          end
        end

        def read_and_parse_outputs(&block)
          logger.warn "Reading the output variables from the Terraform state..."
          outputs_reader.read command: output do |json_outputs:|
            logger.warn "Finished reading the output variables from the Terraform state."

            parse_outputs json_outputs: json_outputs, &block
          end
        end

        def read_client_version
          logger.warn "Reading the Terraform client version..."
          self.client_version = ::Gem::Version.new connection.execute(version).slice /Terraform v(\d+\.\d+\.\d+)/, 1
          logger.warn "Finished reading the Terraform client version."
        end

        def save_outputs(parsed_outputs:, state:)
          logger.warn "Writing the output variables to the Kitchen instance state..."
          outputs_manager.save outputs: parsed_outputs, state: state
          logger.warn "Finished writing the output variables to the Kitchen instance state."
        end

        def save_variables_and_outputs(state:)
          read_and_parse_outputs do |parsed_outputs:|
            save_outputs parsed_outputs: parsed_outputs, state: state
          end
          logger.warn "Writing the input variables to the Kitchen instance state..."
          variables_manager.save variables: variables, state: state
          logger.warn "Finished writing the input variables to the Kitchen instance state."
        end

        def select_workspace
          logger.warn "Selecting the #{workspace_name} Terraform workspace..."
          connection.execute workspace_select
          logger.warn "Finished selecting the #{workspace_name} Terraform workspace."
        end

        def validate_files
          logger.warn "Validating the Terraform configuration files..."
          connection.execute ::Kitchen::Terraform::Command::ValidateFactory.new(version: client_version)
                               .build(config: complete_config)
          logger.warn "Finished validating the Terraform configuration files."
        end
      end
    end
  end
end
