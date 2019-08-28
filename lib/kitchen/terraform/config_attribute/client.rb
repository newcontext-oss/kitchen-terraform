# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
require "kitchen/terraform/config_schemas/string"
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
          def included(plugin_class)
            ::Kitchen::Terraform::ConfigAttributeDefiner.new(
              attribute: self,
              schema: ::Kitchen::Terraform::ConfigSchemas::String,
            ).define plugin_class: plugin_class
            plugin_class.expand_path_for to_sym do |plugin|
              !::TTY::Which.exist? plugin[to_sym]
            end
          end

          # @return [::Symbol] the symbol corresponding to this attribute.
          def to_sym
            :client
          end
        end

        extend ::Kitchen::Terraform::ConfigAttributeCacher

        # @return [::String] </code>"terraform"</code>
        def config_client_default_value
          "terraform"
        end
      end
    end
  end
end
