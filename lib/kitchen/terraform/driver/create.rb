# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "kitchen/terraform/command/init"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/verify_version"

module Kitchen
  module Terraform
    module Driver
      # Create is the class of objects which implement the create action of the driver.
      class Create
        # #call executes the action.
        #
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @return [self]
        def call(workspace_name:, version_requirement:)
          verify_version.call version_requirement: version_requirement
          init.run
          begin
            workspace_select.run workspace_name: workspace_name
          # TODO improve detection of missing workspace
          rescue ::Kitchen::TransientFailure
            workspace_new.run workspace_name: workspace_name
          end
          
          self
        end

        # #initialize prepares a new instance.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @return [Kitchen::Terraform::Driver::Create]
        def initialize(config:, logger:)
          self.init = ::Kitchen::Terraform::Command::Init.new config: config, logger: logger
          self.workspace_new = ::Kitchen::Terraform::Command::WorkspaceNew.new config: config, logger: logger
          self.workspace_select = ::Kitchen::Terraform::Command::WorkspaceSelect.new config: config, logger: logger
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new config: config, logger: logger
        end

        private

        attr_accessor :init, :workspace_new, :workspace_select, :verify_version
      end
    end
  end
end
