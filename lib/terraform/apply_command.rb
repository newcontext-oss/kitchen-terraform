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
require_relative 'color_switch'

module Terraform
  # Command to apply an execution plan
  class ApplyCommand < Command
    include ColorSwitch

    def name
      'apply'
    end

    def options
      "-input=false -state=#{state}#{color_switch}"
    end

    private

    attr_accessor :color, :state

    def initialize_attributes(color:, state:)
      self.color = color
      self.state = state
    end
  end
end
