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

require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_attribute_contract/string"
require "kitchen/terraform/config_attribute_definer"
require "tty/which"

module Kitchen
  module Terraform
    class ConfigAttribute
      # This attribute contains the pathname of the
      # {https://www.terraform.io/docs/commands/index.html Terraform client} to be used by Kitchen-Terraform.
      #
      # If the value is not an absolute pathname or a relative pathname then Kitchen-Terraform will attempt to find the
      # value in the directories of the {https://en.wikipedia.org/wiki/PATH_(variable) PATH}.
      #
      # The pathname of any executable file which implements the interfaces of the following Terraform client commands
      # may be specified: apply; destroy; get; init; validate; workspace.
      #
      # Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760844 Scalar}
      # Required:: False
      # Default:: <code>terraform</code>
      # Example:: <code>client: /usr/local/bin/terraform</code>
      # Example:: <code>client: ./bin/terraform</code>
      # Example:: <code>client: terraform</code>
      module Client
        class << self
          # .included is a callback to define the configuration attribute which is invoked when this module is included
          # in a plugin class.
          #
          # @param plugin_class [Kitchen::Configurable] A plugin class.
          # @return [self]
          def included(plugin_class)
            ::Kitchen::Terraform::ConfigAttributeDefiner.new(
              attribute: self,
              schema: ::Kitchen::Terraform::ConfigAttributeContract::String.new,
            ).define plugin_class: plugin_class
            plugin_class.expand_path_for to_sym do |plugin|
              !::TTY::Which.exist? plugin[to_sym]
            end

            self
          end

          # @return [Symbol] the symbol corresponding to this attribute.
          def to_sym
            :client
          end
        end

        extend ::Kitchen::Terraform::ConfigAttributeCacher

        # @return [String] </code>"terraform"</code>
        def config_client_default_value
          "terraform"
        end

        # #doctor_config_client validates the client configuration.
        #
        # @return [Boolean] +true+ if any errors are found; +false+ if no errors are found.
        def doctor_config_client
          errors = false

          if !::TTY::Which.exist? config_client
            errors = true
            logger.error "client '#{config_client}' is not executable or does not exist"
          end

          errors
        end
      end
    end
  end
end
