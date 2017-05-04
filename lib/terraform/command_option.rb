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

require "terraform"

# An option for a command
class ::Terraform::CommandOption
  attr_reader :key, :value

  def ==(other)
    tuple == other.tuple
  end

  alias eql? ==

  def hash
    stripped_key.hash & stripped_value.hash
  end

  def to_s
    "#{formatted_key}#{formatted_value}"
  end

  def tuple
    [stripped_key, stripped_value]
  end

  private

  attr_accessor :stripped_key, :stripped_value

  attr_writer :key, :value

  def initialize(key:, value: "")
    self.key = key
    self.stripped_key = stripped_string config_string: key
    self.stripped_value = stripped_string config_string: value
    self.value = value
  end

  def formatted_key
    "-#{stripped_key}"
  end

  def formatted_value
    stripped_value.sub /(\S)/, "=\\1"
  end

  def stripped_string(config_string:)
    String(config_string).gsub /\s/, ""
  end
end
