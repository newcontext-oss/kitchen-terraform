# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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
    # SystemAttrsInputsResolver is the class of objects which resolve for systems the attributes derived from Terraform
    # variables.
    class SystemAttrsInputsResolver
      # #initialize prepares a new instance of the class.
      #
      # @param attrs [Hash] a container for attributes.
      # @return [Kitchen::Terraform::SystemAttrsInputsResolver]
      def initialize(attrs:)
        self.attrs = attrs
      end

      # #resolve stores the inputs as attributes.
      #
      # @param inputs [Hash{String=>String}] the variables to be stored as inputs.
      # @return self
      def resolve(inputs:)
        inputs.each_pair do |input_name, input_value|
          attrs.store "input_#{input_name}", input_value
        end

        self
      end

      private

      attr_accessor :attrs
    end
  end
end
