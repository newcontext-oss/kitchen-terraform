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

require_relative 'command'
require_relative 'output_not_found'

module Terraform
  # Command to extract values of output variables
  class OutputCommand
    include Command

    def handle(error:)
      raise OutputNotFound, error.message, error.backtrace if
        error.message =~ /no(?:thing to)? output/
    end

    private

    def initialize_attributes(state:, name:)
      self.name = 'output'
      self.options = { state: state }
      self.target = name
    end
  end
end
