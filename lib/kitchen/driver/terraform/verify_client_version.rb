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
require "kitchen/driver/terraform"

# Verifies that the provided Terraform Client version is supported.
#
# Supported:: Terraform version 0.9.
#
# Deprecated:: Terraform versions 0.7 and 0.8.
#
# Not Supported:: Terraform versions 0.6 and older.
module ::Kitchen::Driver::Terraform::VerifyClientVersion
  extend ::Dry::Monads::Either::Mixin
  extend ::Dry::Monads::Maybe::Mixin
  extend ::Dry::Monads::Try::Mixin

  # Invokes the function.
  #
  # @param version [::Float] the Terraform Client version.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(version:)
    Maybe(version.slice(/v(\d+\.\d+)/, 1)).or do
      Left "Unable to parse Terraform client version output\nTerraform client version output did not match 'vX.Y'"
    end.bind do |major_minor|
      if major_minor == "0.10"
        Right "Terraform version #{major_minor} is supported"
      else
        Left "Terraform version #{major_minor} is not supported; upgrade to Terraform version 0.10"
      end
    end
  end
end
