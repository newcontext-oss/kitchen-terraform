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
require 'terraform/client'
require 'terraform/configurable'
require 'terraform/version'

module Kitchen
  module Driver
    # Terraform state lifecycle activities manager
    class Terraform < ::Kitchen::Driver::Base
      include ::Terraform::Configurable

      kitchen_driver_api_version 2

      no_parallel_for

      def create(_state = nil); end

      def destroy(_state = nil)
        if_state_exist { client.apply_destructively }
      end

      def verify_dependencies
        if_version_not_supported do
          raise ::Kitchen::UserError, "Terraform #{version} is not supported" \
                                        "\nInstall Terraform #{latest_version}"
        end
        if_version_deprecated do
          log_deprecation aspect: "Terraform #{version}",
                          remediation: "Install Terraform #{latest_version}"
        end
      end

      private

      def client
        @client ||= ::Terraform::Client.new config: provisioner, logger: logger
      end

      def deprecated_versions
        @deprecated_versions ||= [::Terraform::Version.new(value: '0.6')]
      end

      def if_state_exist(&block)
        /\w+/.match silent_client.state, &block
      end

      def if_version_deprecated
        deprecated_versions.find proc { return }, &version.method(:==)

        yield
      end

      def if_version_not_supported(&block)
        supported_versions.find block, &version.method(:==)
      end

      def latest_version
        @latest_version ||= ::Terraform::Version.new value: '0.8'
      end

      def silent_client
        ::Terraform::Client.new config: silent_config, logger: debug_logger
      end

      def silent_config
        provisioner.dup.tap { |config| config[:color] = false }
      end

      def supported_version
        @supported_version ||= ::Terraform::Version.new value: '0.7'
      end

      def supported_versions
        @supported_versions ||=
          [latest_version, supported_version] + deprecated_versions
      end

      def version
        @version ||= ::Terraform::Client.new(logger: debug_logger).version
      end
    end
  end
end
