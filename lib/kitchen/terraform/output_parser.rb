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

require "json"
require "kitchen/terraform"
require "kitchen/terraform/error"

# This class parses raw Terraform output.
class ::Kitchen::Terraform::OutputParser
  # This method updates the output held in state.
  #
  # @param output [::String] the output.
  # @return [::String] the output.
  def output=(output)
    @output.replace output
  end

  # This method parses the output as JSON and stores the result in the Test Kitchen state.
  #
  # @param test_kitchen_state [::Hash] the Test Kitchen state.
  # @raise [::Kitchen::Terraform::Error] if the output can not be parsed as JSON.
  # @return [self]
  def parse(test_kitchen_state:)
    test_kitchen_state
      .store(
        :kitchen_terraform_output,
        ::JSON.parse(@output)
      )

    self
  rescue ::JSON::ParserError => parser_error
    raise(
      ::Kitchen::Terraform::Error,
      "Parsing Terraform output as JSON failed: #{parser_error.message}"
    )
  end

  private

  # @api private
  def initialize
    @output = ::String.new "{}"
  end
end
