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
require "kitchen/config/cli"
require "terraform/configurable"
require "terraform/version"

module Kitchen
  module Driver
    # Terraform state lifecycle activities manager
    class Terraform < ::Kitchen::Driver::Base
      ::Kitchen::Config::CLI.call plugin_class: self

      include ::Terraform::Configurable

      kitchen_driver_api_version 2

      no_parallel_for

      def create(_state = nil); end

      def destroy(_state = nil)
        load_state do client.apply_destructively end
      rescue ::Kitchen::StandardError, ::SystemCallError => error
        raise ::Kitchen::ActionFailed, error.message
      end

      def verify_dependencies
        version.if_not_supported do
          raise ::Kitchen::UserError, "#{version} is not supported\nInstall #{::Terraform::Version.latest}"
        end
        version.if_deprecated do
          log_deprecation aspect: version.to_s, remediation: "Install #{::Terraform::Version.latest}"
        end
      end

      private

      def load_state(&block)
        silent_client.load_state(&block)
      rescue ::Errno::ENOENT => error
        debug error.message
      end

      def version
        @version ||= ::Terraform::Client.new(config: self, logger: debug_logger).version
      end
    end
  end
end
