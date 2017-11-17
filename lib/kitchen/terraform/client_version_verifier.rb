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

require "dry/monads"
require "kitchen/terraform"
require "rubygems"

# Verifies that the output of the Terraform Client version subcommand indicates a supported version of Terraform.
class ::Kitchen::Terraform::ClientVersionVerifier
  include ::Dry::Monads::Either::Mixin

  # Verifies output from the Terraform Client version subcommand against the support version.
  #
  # Supported:: Terraform version ~> 0.10.2.
  #
  # @param version_output [::String] the Terraform Client version subcommand output.
  # @return [::Dry::Monads::Either] the result of the function.
  def verify(version_output:)
    Right(
      ::Gem::Version
        .new(
          version_output
            .slice(
              /v(\d+\.\d+\.\d+)/,
              1
            )
        )
    ).bind do |version|
      if requirement.satisfied_by? version
        Right "Terraform v#{version} is supported"
      else
        Left "Terraform v#{version} is not supported; install Terraform ~> v0.10.2"
      end
    end
  end

  private

  attr_reader :requirement

  def initialize
    @requirement = ::Gem::Requirement.new "~> 0.10.2"
  end
end
