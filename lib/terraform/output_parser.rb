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

require 'json'
require 'terraform/deprecated_output_parser'

module Terraform
  # A parser for output command values
  class OutputParser
    def self.create(output:, version:)
      version.if_json_not_supported do
        return ::Terraform::DeprecatedOutputParser.new output: output
      end

      new output: output
    end

    def each_name(&block)
      json_output.each_key(&block)
    end

    def iterate_parsed_output(&block)
      Array(parsed_output).each(&block)
    end

    def parsed_output
      json_output.fetch 'value'
    end

    private

    attr_accessor :output

    def initialize(output:)
      self.output = output
    end

    def json_output
      ::JSON.parse output
    end
  end
end
