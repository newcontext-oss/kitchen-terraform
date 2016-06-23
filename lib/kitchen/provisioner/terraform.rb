# frozen_string_literal: true

require 'kitchen'
require 'pathname'
require 'terraform/client_holder'
require 'terraform/version'

module Kitchen
  module Provisioner
    # Terraform configuration applier
    class Terraform < Base
      include ::Terraform::ClientHolder

      kitchen_provisioner_api_version 2

      plugin_version ::Terraform::VERSION

      def call(_state = nil)
        client.validate_configuration_files
        client.download_modules
        client.plan_execution
        client.apply_execution_plan
      rescue => error
        raise Kitchen::ActionFailed, error.message, error.backtrace
      end

      def directory
        config.fetch(:directory) { kitchen_root }
      end

      def kitchen_root
        Pathname.new config.fetch :kitchen_root
      end

      def variable_files
        config.fetch(:variable_files) { [] }
      end

      def variables
        config.fetch(:variables) { [] }
      end
    end
  end
end
