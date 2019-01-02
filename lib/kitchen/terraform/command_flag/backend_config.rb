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

require "kitchen"

module Kitchen
  module Terraform
    module CommandFlag
      # BackendConfig provides logic to handle the `-backend-config` flag.
      class BackendConfig
        def to_s
          @backend_config.inject @command.to_s do |command, (name, value)|
            command.concat " -backend-config=\"#{name}=#{value}\""
          end
        end

        private

        def initialize(backend_config:, command:)
          @backend_config = backend_config
          @command = command
        end
      end
    end
  end
end
