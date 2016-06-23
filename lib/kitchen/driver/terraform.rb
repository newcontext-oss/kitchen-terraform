# frozen_string_literal: true

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
