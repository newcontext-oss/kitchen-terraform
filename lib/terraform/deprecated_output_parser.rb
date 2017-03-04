# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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
  # A parser for deprecated output command values
  class DeprecatedOutputParser
    def each_name(&block)
      output.scan(/(\w+)\s*=/).flatten.each(&block)
    end

    def iterate_parsed_output(&block)
      Array(parsed_output)
        .each { |list_value| list_value.split(',').each(&block) }
    end

    def parsed_output
      output.strip
    end

    private

    attr_accessor :output

    def initialize(output:)
      self.output = output
    end
  end
end
