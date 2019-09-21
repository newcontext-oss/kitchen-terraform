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

require "kitchen"

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
        system.add_attrs(
          attrs: resolved_inputs.merge(
            resolved_outputs.merge(
              attrs_outputs_keys.lazy.map(&:to_s).zip(resolved_outputs.fetch_values(*attrs_outputs_values)).to_h
            )
          ),
        )

        self
      rescue ::KeyError => key_error
        @logger.error(key_error)

        raise ::Kitchen::ClientError, "Failed resolution of attributes."
      end

      private

      def initialize(inputs:, logger:, outputs:)
        @inputs = Hash[inputs]
        @logger = logger
        @outputs = Hash[outputs]
      end

      def resolved_inputs
        @inputs.map do |key, value|
          ["input_#{key}", value]
        end.to_h
      end

      def resolved_outputs
        @resolved_outputs ||= @outputs.map do |key, value|
          [key.to_s, value]
        end.to_h.merge(@outputs.map do |key, value|
          ["output_#{key}", value]
        end.to_h).map do |key, value|
          begin
            [key, value.fetch(:value)]
          rescue ::KeyError => key_error
            @logger.error(
              "The key 'value' was not found in the '#{key}' output in the Kitchen instance state. This error could " \
              "indicate that the Kitchen instance state was modified after `kitchen converge` was executed or that " \
              "the format of `terraform output -json` has changed."
            )

            raise ::Kitchen::ClientError, "Failed resolution of attributes."
          end
        end.to_h
      end
    end
  end
end
