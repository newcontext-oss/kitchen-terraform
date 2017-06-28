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
require "kitchen"
require "kitchen/terraform"
require "kitchen/terraform/define_config_attribute"

# Defines an integer configuration attribute for a plugin class.
#
# @see http://dry-rb.org/gems/dry-validation/ DRY Validation
module ::Kitchen::Terraform::DefineIntegerConfigAttribute
  # Invokes the function.
  #
  # @param attribute [::Symbol] the name of the attribute.
  # @param plugin_class [::Class] the plugin class on which the attribute will be defined.
  # @yieldparam plugin [::Kitchen::Driver::Terraform, ::Kitchen::Provisioner::Terraform, ::Kitchen::Verifier::Terraform]
  #             an instance of the plugin class.
  # @yieldreturn [::Object] the default value of the attribute.
  def self.call(attribute:, plugin_class:, &initialize_default_value)
    ::Kitchen::Terraform::DefineConfigAttribute.call(
      attribute: attribute,
      initialize_default_value: initialize_default_value,
      plugin_class: plugin_class,
      schema: lambda do
        required(:value).filled :int?
      end
    )
  end
end
