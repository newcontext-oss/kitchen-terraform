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
  # Manages options for Terraform commands
  class CommandOptions
    def to_s
      key_flags.each_with_object String.new('') do |(flag, values), string|
        values.each { |value| string.concat "#{flag}=#{value} " }
      end.chomp ' '
    end

    private

    attr_accessor :options

    def key_flags
      options
        .map { |key, value| [key.to_s.tr('_', '-').prepend('-'), value] }.to_h
    end

    def initialize(**options)
      self.options = options
      normalize_values
      yield self if block_given?
    end

    def normalize_values
      options.each_pair { |key, value| options.store key, Array(value) }
    end
  end
end
