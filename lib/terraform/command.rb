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

require "terraform/command_options"

module Terraform
  # Terraform command to be executed
  class Command
    attr_reader :options, :target

    def name
      /(\w+)Command/.match self.class.to_s do |match| return match[1].downcase end

      "help"
    end

    def prepare
      preparations.each &:execute
    end

    def to_s
      "#{name} #{options} #{target}".strip
    end

    private

    attr_accessor :preparations

    attr_writer :options, :target

    def initialize(target: "", &block)
      block ||= proc do end

      self.options = ::Terraform::CommandOptions.new
      self.preparations = []
      self.target = target
      block.call options
    end
  end
end
