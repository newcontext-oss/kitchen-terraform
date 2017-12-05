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

require "kitchen/terraform"
require "kitchen/terraform/error"
require "rubygems"

# Verifies that the output of the Terraform version command indicates a supported version of Terraform.
#
# Supported:: Terraform version ~> 0.10.2.
class ::Kitchen::Terraform::ClientVersionVerifier
  # Verifies output from the Terraform version command against the support version.
  #
  # @param version_output [::String] the Terraform Client version subcommand output.
  # @raise [::Kitchen::Terraform::Error] if the version is not supported.
  # @return [::String] a confirmation that the version is supported.
  def verify(version_output:)
    ::Gem::Version
      .new(
        version_output
          .slice(
            /v(\d+\.\d+\.\d+)/,
            1
          )
      )
      .tap do |version|
        requirement
          .satisfied_by? version or
            fail(
              ::Kitchen::Terraform::Error,
              "Terraform v#{version} is not supported; install Terraform ~> v0.11.0"
            )

        return "Terraform v#{version} is supported"
      end
  end

  private

  attr_reader :requirement

  def initialize
    @requirement =
      ::Gem::Requirement
        .new(
          ">= 0.10.2",
          "< 0.12.0"
        )
  end
end
