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

require 'fileutils'
require 'kitchen'
require 'terraform/client'
require 'terraform/configurable'

module Kitchen
  module Driver
    # Terraform state lifecycle activities manager
    class Terraform < Base
      include ::Terraform::Client

      include ::Terraform::Configurable

      kitchen_driver_api_version 2

      no_parallel_for

      def create(_state = nil)
        %i(plan state)
          .each { |option| FileUtils.mkdir_p File.dirname provisioner[option] }
      end

      def destroy(_state = nil)
        return if !File.exist?(provisioner[:state]) || current_state.empty?

        create
        validate_configuration_files
        download_modules
        plan_execution destroy: true
        apply_execution_plan
      end

      def verify_dependencies
        case version
        when /v0\.7/
        when /v0\.6/
          log_deprecation aspect: version, remediation: 'Update to v0.7',
                          version: '1.0'
        else
          raise Kitchen::UserError, 'Only Terraform v0.7 and v0.6 are supported'
        end
      end
    end
  end
end
