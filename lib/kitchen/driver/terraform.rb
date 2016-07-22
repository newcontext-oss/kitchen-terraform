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
require 'terraform/client_holder'
require 'terraform/invalid_version'
require 'terraform/version'

module Kitchen
  module Driver
    # Terraform state lifecycle activities manager
    class Terraform < Base
      include ::Terraform::ClientHolder

      kitchen_driver_api_version 2

      plugin_version ::Terraform::VERSION

      no_parallel_for

      def create(_state = nil)
        client.fetch_version do |output|
          raise ::Terraform::InvalidVersion, supported_version, caller unless
            output.match supported_version
        end
      rescue => error
        raise Kitchen::ActionFailed, error.message, error.backtrace
      end

      def destroy(_state = nil)
        client.validate_configuration_files
        client.download_modules
        client.plan_destructive_execution
        client.apply_execution_plan
      rescue => error
        raise Kitchen::ActionFailed, error.message, error.backtrace
      end

      def supported_version
        'v0.6'
      end
    end
  end
end
