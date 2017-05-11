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

require "kitchen/terraform/client"

::Kitchen::Terraform::Client::ProcessOptions = lambda do |unprocessed_options:|
  throw(
    :success,
    unprocessed_options.map do |key, value|
      case key
      when :color
        "-no-color" if not value
      when :destroy
        "-destroy" if value
      when :input
        "-input=#{value}"
      when :json
        "-json" if value
      when :out
        "-out=#{value}"
      when :parallelism
        "-parallelism=#{value}"
      when :state
        "-state=#{value}"
      when :state_out
        "-state-out=#{value}"
      when :update
        "-update" if value
      when :var
        value.map do |variable_name, variable_value|
          "-var='#{variable_name}=#{variable_value}'"
        end
      when :var_file
        value.map do |file|
          "-var-file=#{file}"
        end
      else
        throw :failure,
              "'#{key}' is not supported as a ::Kitchen::Terraform::Client option"
      end
    end.compact.flatten
  )
end
