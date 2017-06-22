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
require "fileutils"
require "kitchen/driver/terraform"

# Creates directories on the filesystem.
module ::Kitchen::Driver::Terraform::CreateDirectories
  extend ::Dry::Monads::Either::Mixin
  extend ::Dry::Monads::Try::Mixin

  # Invokes the function.
  #
  # @param directories [::Array<::String>, ::String] the list of directories to create.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(directories:)
    Try ::SystemCallError do
      ::FileUtils.makedirs directories
    end.to_either.bind do
      Right "Created directories #{directories}"
    end.or do |error|
      Left error.to_s
    end
  end
end
