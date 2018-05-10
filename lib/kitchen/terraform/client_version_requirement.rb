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
require "rubygems"

class ::Kitchen::Terraform::ClientVersionRequirement
  def if_not_satisfied(client_version:)
    self.version = client_version

    requirement
      .satisfied_by? version or
      yield message: not_satisfied_message
  end

  private

  attr_reader(
    :requirement,
    :version
  )

  # @api private
  def initialize(requirement:)
    self.requirement = requirement
  end

  # @api private
  def not_satisfied_message
    "The version of Terraform in use does not satisfy the requirement of #{requirement}"
  end

  # @api private
  def requirement=(requirement)
    @requirement = ::Gem::Requirement.create *Array(requirement)
  end

  # @api private
  def version=(version)
    @version =
      ::Gem::Version
        .create(
          version
            .slice(
              /(\d+\.\d+\.\d+)/,
              1
            )
        )
  end
end
