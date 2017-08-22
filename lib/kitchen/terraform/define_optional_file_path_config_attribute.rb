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

require "dry-validation"
require "kitchen/terraform"
require "kitchen/terraform/define_config_attribute"

# Defines an optional file path configuration attribute for a plugin class. If the attribute is associated in the
# configuration then its value must be a string and its value is assumed to be a file path that is expandable relative
# to the working directory of Test Kitchen. If the attribute is not associated in the configuration then it has no
# value.
#
# @see http://dry-rb.org/gems/dry-validation/ DRY Validation
module ::Kitchen::Terraform::DefineOptionalFilePathConfigAttribute
  # Invokes the function.
  #
  # @param attribute [::Symbol] the name of the attribute.
  # @param plugin_class [::Class] the plugin class on which the attribute will be defined.
  def self.call(attribute:, plugin_class:)
    ::Kitchen::Terraform::DefineConfigAttribute.call(
      attribute: attribute,
      expand_path: true,
      initialize_default_value: lambda do |_|
        nil
      end,
      plugin_class: plugin_class,
      schema: lambda do
        optional(:value)
          .maybe(
            :str?,
            :filled?
          )
      end
    )
  end
end
