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
require "kitchen/terraform/command/version"
require "kitchen/terraform/error"

# Verifies that the output of the Terraform version command indicates a supported version of Terraform.
#
# Supported:: Terraform version >= 0.11.4, < 0.12.0.
module ::Kitchen::Terraform::VerifyVersion
  class << self
    # Runs the function.
    #
    # @raise [::Kitchen::Terraform::Error] if the version is not supported or `terraform version` fails.
    # @return [void]
    def call
      ::Kitchen::Terraform::Command::Version.call do |version:|
        version.if_satisfies requirement: [">= 0.11.4", "< 0.12.0"] do
          return
        end

        raise(
          ::Kitchen::Terraform::Error,
          "The installed version of Terraform is not supported; install Terraform ~> v0.11.4"
        )
      end
    end
  end
end
