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
    # SystemAttrsOutputsResolver is the class of objects which resolve for systems the attrs which are derived from
    # Terraform outputs.
    class SystemAttrsOutputsResolver
      # #initialize prepares a new instance of the class.
      #
      # @param attrs [::Hash] a container for attributes.
      # @param logger [::Kitchen::Logger] a logger to log messages.
      def initialize(attrs:, logger:)
        self.attrs = attrs
        self.logger = logger
      end

      # #resolve fetches Terraform outputs and associates them with InSpec attributes.
      #
      # @param attrs_outputs [::Hash<::String, ::String>] a mapping of InSpec attribute names to Terraform output names.
      # @param outputs [::Hash<::String, ::Hash>] Terraform outputs.
      # @raise [::Kitchen::TransientFailure] if the resolution fails.
      # @return [self]
      def resolve(attrs_outputs:, outputs:)
        resolve_defaults outputs: outputs
        resolve_configuration attrs_outputs: attrs_outputs

        yield attrs: attrs

        self
      end

      private

      attr_accessor :attrs, :logger

      def resolve_configuration(attrs_outputs:)
        attrs_outputs.each_pair do |attr_name, output_name|
          begin
            attrs.store attr_name.to_s, attrs.fetch("output_#{output_name}")
          rescue ::KeyError
            logger.error(
              "The '#{output_name}' key was not found in the Terraform outputs of the Kitchen instance state. This " \
              "error indicates that the available Terraform outputs need to be updated with `kitchen converge` or " \
              "that the wrong key was provided."
            )

            raise ::Kitchen::TransientFailure, "Resolution of attributes failed."
          end
        end
      end

      def resolve_defaults(outputs:)
        outputs.each_pair do |output_name, output_body|
          begin
            attrs.store output_name.to_s, attrs.store("output_#{output_name}", output_body.fetch(:value))
          rescue ::KeyError
            logger.error(
              "The 'value' key was not found in the '#{output_name}' Terraform output of the Kitchen instance state. " \
              "This error indicates that the output format of `terraform output -json` is unexpected."
            )

            raise ::Kitchen::TransientFailure, "Resolution of attributes failed."
          end
        end
      end
    end
  end
end
