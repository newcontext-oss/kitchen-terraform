# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "kitchen/terraform/error"
require "kitchen/verifier/terraform"

# Configures the InSpec profile attributes for the Inspec::Runner used by the verifier to verify a system.
#
# Three different maps are merged to create the profile attributes.
#
# The first map is comprised of attributes that are external to the Terraform state.
#
#   {
#     "terraform_state" => "/path/to/terraform/state"
#   }
#
# The second map is comprised of attributes that represent the Terraform output variables of the Terraform state. This
# map takes precedence in any key conflicts with the first map.
#
#   {
#     "first_output_variable_name" => "first_output_variable_value",
#     "second_output_variable_name" => "second_output_variable_value"
#   }
#
# The third map is comprised of attributes defined by a system's +:attributes+; the keys are converted to strings and the
# values are assumed to be Terraform output variable names which are resolved. This map takes precedence in any key
# conflicts with the second map.
#
#   {
#     first_attribute_name: "second_output_variable_name"
#   }
#
#   # becomes
#
#   {
#     "first_attribute_name" => "second_output_variable_value"
#   }
#
# @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb Inspec::Runner
# @see https://github.com/chef/kitchen-inspec/blob/master/lib/kitchen/verifier/inspec.rb kitchen-inspec verifier
# @see https://www.inspec.io/docs/reference/profiles/ InSpec Profiles
# @see https://www.terraform.io/docs/configuration/outputs.html Terraform output variables
# @see https://www.terraform.io/docs/state/index.html Terraform state
module ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
  class << self
    # Invokes the function
    #
    # @param system [::Hash] a kitchen-terraform verifier system.
    # @param options [::Hash] the InSpec Runner options.
    # @param outputs [::String] the outputs of the Terraform state.
    # @raise [::Kitchen::Terraform::Error] if the configuration fails.
    # @return [void]
    def call(system:, options:, outputs:)
      system.fetch :attributes do
        {}
      end
        .tap do |system_attributes|
          options.store(
            :attributes,
            resolve(system_attributes: system_attributes, outputs: outputs)
          )
        end
    rescue ::KeyError => key_error
      raise ::Kitchen::Terraform::Error, "Configuring InSpec runner attributes resulted in failure: #{key_error.message}"
    end

    private

    # @api private
    def meld(system_attributes:, outputs:)
      outputs.keys.tap do |outputs_keys|
        return outputs_keys.+(system_attributes.keys).zip outputs_keys.+ system_attributes.values
      end
    end

    # @api private
    def resolve(system_attributes:, outputs:)
      meld(system_attributes: system_attributes, outputs: outputs)
        .reduce(::Hash.new) do |resolved_attributes, (attribute_name, output_name)|
          resolved_attributes.merge(attribute_name.to_s => outputs.fetch(output_name.to_s).fetch("value"))
        end
    end
  end
end
