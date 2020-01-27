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

require "kitchen/terraform/command/version"
require "kitchen/terraform/version_verifier"

module Kitchen
  module Terraform
      # VerifyVersion is the class of objects which verify the version of the Terraform client against a version 
      # requirement.
      class VerifyVersion
        # #call invokes the verification.
        #
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @return [self]
        def call(version_requirement:)
          version_verifier.verify(
            options: { cwd: root_module_directory },
            requirement: version_requirement,
            strict: verify_version,
          )
          
          self
        end

        # #initialize prepares a new instance.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @option config [String] :client the pathname of the Terraform client.
        # @option config [String] :root_module_directory the pathname of the directory which contains the root 
        #   Terraform module.
        # @option config [Boolean] :verify_version a toggle of strict or permissive verification of support for the 
        #   version of the Terraform client.
        # @return [Kitchen::Terraform::VerifyVersion]
        def initialize(config:, logger:)
          self.root_module_directory = config.fetch :root_module_directory
          self.verify_version = config.fetch :verify_version
          self.version_verifier = ::Kitchen::Terraform::VersionVerifier.new(
            command: ::Kitchen::Terraform::Command::Version.new(client: config.fetch(:client), logger: logger),
            logger: logger,
          )
        end

        private

        attr_accessor :root_module_directory, :verify_version, :version_verifier
      end
    end
  end
