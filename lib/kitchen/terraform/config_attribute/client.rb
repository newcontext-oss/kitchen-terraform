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

require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_attribute_definer"
require "kitchen/terraform/config_attribute_type/pathname_of_executable_file"
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
      # Default:: The pathname of the Terraform client on the PATH.
      # Example:: <code>client: /usr/local/bin/terraform</code>
      # Example:: <code>client: ./bin/terraform</code>
      # Example:: <code>client: terraform</code>
      #
      # @abstract It must be included by a plugin class in order to be used.
      module Client
        ::Kitchen::Terraform::ConfigAttributeType::PathnameOfExecutableFile.apply(
          attribute: :client,
          config_attribute: self,
          default_value: lambda do
            ::TTY::Which.which "terraform"
          end,
        )
      end
    end
  end
end
