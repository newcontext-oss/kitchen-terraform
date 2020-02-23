# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "json"
require "kitchen"

module Kitchen
  module Terraform
    # OutputsParser parses Terraform output variables as JSON.
    class OutputsParser
      # #parse parses the outputs.
      #
      # @param json_outputs [String] the output variables as a string of JSON.
      # @raise [Kitchen::TransientFailure] if parsing the output variables fails.
      # @yieldparam parsed_outputs [Hash] the output variables as a hash.
      # @return [self]
      def parse(json_outputs:)
        yield parsed_outputs: ::JSON.parse(json_outputs)

        self
      rescue ::JSON::ParserError
        raise ::Kitchen::TransientFailure, "Parsing the Terraform output variables as JSON failed."
      end
    end
  end
end
