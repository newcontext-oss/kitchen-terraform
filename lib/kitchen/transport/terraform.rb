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

require "kitchen/terraform/config_attribute/client"
require "kitchen/terraform/configurable"
require "kitchen/terraform/transport/connection"
require "kitchen/terraform/transport/doctor"
require "kitchen/transport/exec"

module Kitchen
  # This namespace is defined by Kitchen.
  #
  # @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Transport
  module Transport
    # The transport is responsible for the communication with an instance,
    # that is Terraform CLI comands.
    #
    # === Configuration Attributes
    #
    # The configuration attributes of the transport control the behaviour of the Terraform commands that are run.
    # Within the
    # {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}, these attributes must be
    # declared in the +transport+ mapping along with the plugin name.
    #
    #   tarnsport:
    #     name: terraform
    #     a_configuration_attribute: some value
    #
    # ==== client
    #
    # {include:Kitchen::Terraform::ConfigAttribute::Client}
    #
    # === Ruby Interface
    #
    # This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
    # :reek:MissingSafeMethod { exclude: [ finalize_config! ] }
    #
    # @version 2
    class Terraform < ::Kitchen::Transport::Exec
      kitchen_transport_api_version 2

      include ::Kitchen::Terraform::ConfigAttribute::Client

      include ::Kitchen::Terraform::Configurable

      # #connection creates a new Connection, configured by a merging of configuration
      # and state data.
      #
      # @param state [Hash] mutable instance state.
      # @return [Kitchen::Terraform::Transport::Connection] a connection for this transport.
      # @raise [Kitchen::TransportFailed] if a connection could not be returned.
      def connection(state, &block)
        options = connection_options config.to_hash.merge state

        ::Kitchen::Terraform::Transport::Connection.new options, &block
      end

      # doctor checks the system and configuration for common errors.
      #
      # @param state [Hash] the mutable Kitchen instance state.
      # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
      def doctor(state)
        ::Kitchen::Terraform::Transport::Doctor.new(
          instance_name: instance.name,
          logger: logger,
        ).call config: config
      end

      # #finalize_config! invokes the super implementation and then initializes the strategies.
      #
      # @param instance [Kitchen::Instance] an associated instance.
      # @raise [Kitchen::ClientError] if the instance is nil.
      # @return [self]
      def finalize_config!(instance)
        super instance

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param config [Hash] the transport configuration.
      # @return [Kitchen::Transport::Terraform]
      def initialize(config = {})
        super config
      end

      private

      # #connection_options builds the hash of options needed by the Connection object on construction.
      #
      # @param data [Hash] merged configuration and mutable state data.
      # @return [Hash] hash of connection options.
      # @api private
      def connection_options(data)
        opts = super

        opts.store :client, config.fetch(:client)
        opts.store :logger, logger

        opts
      end
    end
  end
end
