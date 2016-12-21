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
  # Command to plan an execution
  class PlanCommand < Command
    include ColorSwitch

    def name
      'plan'
    end

    def options
      "-destroy=#{destroy} -input=false -out=#{out} " \
        "-parallelism=#{parallelism} -state=#{state} " \
        "#{color_switch}#{processed_variables}#{processed_variable_files}"
    end

    private

    attr_accessor :destroy, :out, :parallelism, :state, :variables,
                  :variable_files

    def initialize_attributes(
      color:, destroy:, out:, parallelism:, state:, variables:, variable_files:
    )
      self.color = color
      self.destroy = destroy
      self.out = out
      self.parallelism = parallelism
      self.state = state
      self.variables = variables
      self.variable_files = variable_files
    end

    def processed_variable_files
      variable_files.each_with_object String.new do |pathname, string|
        string.concat " -var-file=#{pathname}"
      end
    end

    def processed_variables
      variables.each_with_object String.new do |(key, value), string|
        string.concat " -var='#{key}=#{value}'"
      end
    end
  end
end
