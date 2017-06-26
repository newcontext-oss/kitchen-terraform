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

require "dry/monads"
require "kitchen/terraform/client"

# Processes Terraform Client function options in to Terraform Command-Line Interface (CLI) flags.
#
# @see https://www.terraform.io/docs/commands/index.html Terraform commands
module ::Kitchen::Terraform::Client::ProcessOptions
  extend ::Dry::Monads::Either::Mixin
  extend ::Dry::Monads::Maybe::Mixin
  extend ::Dry::Monads::List::Mixin
  extend ::Dry::Monads::Try::Mixin

  OPTIONS_FLAGS = {
    color: lambda do |value:|
      "-no-color" if not value
    end,
    destroy: lambda do |value:|
      "-destroy" if value
    end,
    input: lambda do |value:|
      "-input=#{value}"
    end,
    json: lambda do |value:|
      "-json" if value
    end,
    out: lambda do |value:|
      "-out=#{value}"
    end,
    parallelism: lambda do |value:|
      "-parallelism=#{value}"
    end,
    state: lambda do |value:|
      "-state=#{value}"
    end,
    state_out: lambda do |value:|
      "-state-out=#{value}"
    end,
    update: lambda do |value:|
      "-update" if value
    end,
    var: lambda do |value:|
      value.map do |variable_name, variable_value|
        "-var='#{variable_name}=#{variable_value}'"
      end
    end,
    var_file: lambda do |value:|
      value.map do |file|
        "-var-file=#{file}"
      end
    end
  }.freeze

  # Invokes the function.
  #
  # @param unprocessed_options [::Hash{::Symbol => TrueClass, FalseClass, #to_s, #map}] underscore delimited option keys
  #        associated with their values.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(unprocessed_options:)
    List(unprocessed_options.to_a).fmap(&method(:Right)).typed(::Dry::Monads::Either).traverse do |member|
      member.bind do |key, value|
        Maybe(::Kitchen::Terraform::Client::ProcessOptions::OPTIONS_FLAGS[key]).bind do |processor|
          Right processor.call value: value
        end.or do
          Left ":#{key} is not a supported Terraform Client option"
        end
      end
    end.fmap do |options|
      options.value.flatten.compact.sort
    end
  end
end
