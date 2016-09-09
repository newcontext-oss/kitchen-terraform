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

require 'kitchen'
require 'terraform/configurable'
require 'terraform/version'

module Kitchen
  module Driver
    # Terraform state lifecycle activities manager
    class Terraform < Base
      include ::Terraform::Configurable

      kitchen_driver_api_version 2

      plugin_version ::Terraform::VERSION

      no_parallel_for

      def create(_state = nil)
        raise UserError,
              'Only Terraform versions 0.6.z and 0.7.z are supported' unless
                supported_version.match provisioner.installed_version
      end

      def destroy(_state = nil)
        provisioner.validate_configuration_files
        provisioner.download_modules
        provisioner.plan_destructive_execution
        provisioner.apply_execution_plan
      end

      private

      def supported_version
        /v0\.[67]/
      end
    end
  end
end
