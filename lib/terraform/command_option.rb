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

module Terraform
  # An option for a command
  class CommandOption
    attr_reader :key, :value

    def ==(other)
      tuple == other.tuple
    end

    alias eql? ==

    def hash
      key.hash & value.hash
    end

    def to_s
      "-#{key}#{formatted_value}"
    end

    def tuple
      [key, value]
    end

    private

    attr_writer :key, :value

    def formatted_value
      String(value).sub(/(\S)/, '=\1')
    end

    def initialize(key:, value: '')
      self.key = key
      self.value = value
    end
  end
end
