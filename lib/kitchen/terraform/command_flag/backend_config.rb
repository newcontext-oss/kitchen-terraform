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

module Kitchen
  module Terraform
    module CommandFlag
      # BackendConfig is the class of objects which control the arguments to the backend configuration.
      class BackendConfig
        # #initialize prepares a new instance of the class.
        #
        # @param arguments [Hash{String=>String}] the arguments.
        # @return [Kitchen::Terraform::CommandFlag::BackendConfig]
        def initialize(arguments:)
          self.arguments = arguments
        end

        # @return [String] the backend configuration flag.
        def to_s
          arguments.map do |key, value|
            "-backend-config=\"#{key}=#{value}\""
          end.join " "
        end

        private

        attr_accessor :arguments
      end
    end
  end
end
