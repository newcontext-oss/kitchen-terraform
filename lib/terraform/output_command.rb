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
require_relative 'command_extender'
require_relative 'zero_six_output'
require_relative 'zero_seven_output'

module Terraform
  # Command to extract values of output variables
  class OutputCommand < Command
    include CommandExtender

    def name
      'output'
    end

    private

    attr_accessor :list, :state

    def initialize_attributes(list:, version:, state:)
      extend_behaviour version: version
      self.list = list
      self.state = state
    end

    def version_behaviours
      { /v0.7/ => ZeroSevenOutput, /v0.6/ => ZeroSixOutput }
    end
  end
end
