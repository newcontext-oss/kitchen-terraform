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
require "kitchen/terraform"

# Clears a directory on the filesystem of specified files.
module ::Kitchen::Terraform::ClearDirectory
  extend ::Dry::Monads::Either::Mixin

  # Invokes the function.
  #
  # @param directory ::String the path of the directory to clear.
  # @param files [::Array<::String>, ::String] a list of files to clear from the directory.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(directory:, files:, &block)
    ::FileUtils.safe_unlink(
      files.map do |file|
        ::Dir.glob ::File.join directory, file
      end.flatten
    )
    block.call "Cleared directory \"#{directory}\" of files #{files}"
  end
end
