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
    # OutputsReader is the class of objects which read Terraform output variables.
    class OutputsReader
      # #read reads the output variables.
      #
      # @param command [Kitchen::Terraform::Command::Output] the output command.
      # @raise [Kitchen::TransientFailure] if running the output command fails.
      # @yieldparam json_outputs [String] the output variables as a string of JSON.
      # @return [self]
      def read(command:)
        json_outputs = "{}"

        begin
          json_outputs = connection.execute command
        rescue ::Kitchen::StandardError => error
          no_outputs_defined.match ::Regexp.escape error.original.to_s or raise ::Kitchen::TransientFailure, error.message
        end

        yield json_outputs: json_outputs

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param connection [Kitchen::Terraform::Transport::Connection] a Terraform connection.
      # @return [Kitchen::Terraform::OutputsReader]
      def initialize(connection:)
        self.connection = connection
        self.no_outputs_defined = /no\\ outputs\\ defined/
      end

      private

      attr_accessor :connection, :no_outputs_defined
    end
  end
end
