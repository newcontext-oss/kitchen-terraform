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

require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_attribute_type/hash_of_symbols_and_strings"
require "shellwords"

module Kitchen
  module Terraform
    class ConfigAttribute
      # This attribute comprises {https://www.terraform.io/docs/configuration/variables.html Terraform variables}.
      #
      # Type:: {http://www.yaml.org/spec/1.2/spec.html#id2760142 Mapping of scalars to scalars}
      # Required:: False
      # Example::
      #   _
      #     variables:
      #       image: image-1234
      #       zone: zone-5
      module Variables
        ::Kitchen::Terraform::ConfigAttributeType::HashOfSymbolsAndStrings.apply(
          attribute: :variables,
          config_attribute: self,
          default_value: lambda do
            {}
          end,
        )

        def config_variables_flags
          config_variables.map do |key, value|
            "-var=\"#{::Shellwords.escape key}=#{::Shellwords.join ::Shellwords.split value}\""
          end.join " "
        end
      end
    end
  end
end
