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

require "kitchen/terraform"
require "kitchen/terraform/error"

module Kitchen
  module Terraform
    # SystemAttrsResolver is the class of objects which resolve for systems the attrs which are contained in outputs.
    class SystemAttrsResolver
      # #resolve resolves the attrs.
      #
      # @param attrs_outputs_keys [::Array<::String>] the names of the InSpec attributes.
      # @param attrs_outputs_values [::Array<::String>] the names of the Terraform outputs.
      # @param system [::Kitchen::Terraform::System] the system.
      # @raise [::Kitchen::Terraform::Error] if the fetching the value of the output fails.
      def resolve(attrs_outputs_keys:, attrs_outputs_values:, system:)
        system.add_attrs(attrs: @inputs.merge(@outputs.merge(
                           attrs_outputs_keys.lazy.map(&:to_s).zip(@outputs.fetch_values(*attrs_outputs_values)).to_h
                         )))

        self
      rescue ::KeyError => key_error
        raise ::Kitchen::Terraform::Error, "Resolving attrs failed\n#{key_error}"
      end

      private

      # #initialize prepares the instance to be used.
      #
      # @param outputs [#to_hash] the outputs of the Terraform state under test.
      def initialize(inputs:, outputs:)
        @inputs = inputs.transform_keys do |key|
          "input_#{key}"
        end
        @outputs = Hash[outputs].transform_values do |value|
          value.fetch("value")
        end
        @outputs.merge!(@outputs.transform_keys do |key|
          "output_#{key}"
        end)
      rescue ::KeyError => key_error
        raise ::Kitchen::Terraform::Error, "Preparing to resolve attrs failed\n#{key_error}"
      end
    end
  end
end
