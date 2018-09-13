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
require "kitchen/terraform/error"
require "kitchen/terraform/version"

module Kitchen
  module Terraform
    # Refinements to Kitchen::Configurable.
    #
    # @see https://github.com/test-kitchen/test-kitchen/blob/v1.16.0/lib/kitchen/configurable.rb Kitchen::Configurable
    module Configurable
      # A callback to define the plugin version which is invoked when this module is included in a plugin class.
      #
      # @return [self]
      def self.included(configurable_class)
        ::Kitchen::Terraform::Version.assign_plugin_version configurable_class: configurable_class
        self
      end

      # doctor checks the system and configuration for common errors.
      #
      # @param _kitchen_state [::Hash] the mutable Kitchen instance state.
      # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
      # @see https://github.com/test-kitchen/test-kitchen/blob/v1.21.2/lib/kitchen/verifier/base.rb#L85-L91
      def doctor(_kitchen_state)
        return false if deprecated_config.empty?

        deprecated_config.each_pair do |attribute, message|
          logger.warn "The #{attribute} configuration attribute is deprecated.\n#{message}"
        end

        return true
      end

      private

      # @note this method should be removed when
      #   {https://github.com/test-kitchen/test-kitchen/issues/1229 Kitchen: Issue #1229} is solved.
      def expand_paths!
        validate_config! if not @config_validated
        super
      end

      # #execute_action yields to a block which contains a Kitchen action.
      #
      # @yield [] gives no value to the block.
      # @raise [::Kitchen::ActionFailed] if a Kitchen Terraform Error.
      def execute_action
        yield
      rescue ::Kitchen::Terraform::Error => error
        raise ::Kitchen::ActionFailed, error.message
      end

      # @note this method should be removed when
      #   {https://github.com/test-kitchen/test-kitchen/issues/1229 Kitchen: Issue #1229} is solved.
      def validate_config!
        return if @config_validated

        super
        @config_validated = true
      end
    end
  end
end
