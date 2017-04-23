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

require 'fileutils'

module Terraform
  # A preparation for a command with an output file
  class PrepareOutputFile
    def execute
      parent_directory.mkpath
      file.open('a') {}
    end

    private

    attr_accessor :file, :parent_directory

    def initialize(file:)
      self.file = file
      self.parent_directory = file.parent
    end
  end
end
