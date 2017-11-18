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

require "dry/monads"
require "kitchen/verifier/terraform"

# Configures the InSpec profile attributes for the Inspec::Runner used by the verifier to verify a group.
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
# The third map is comprised of attributes defined by a group's +:attributes+; the keys are converted to strings and the
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
  extend ::Dry::Monads::Either::Mixin

  extend ::Dry::Monads::Maybe::Mixin

  extend ::Dry::Monads::Try::Mixin

  # Invokes the function
  #
  # @param group [::Hash] a kitchen-terraform verifier group.
  # @param output [::String] the output of the Terraform state.
  # @return [::Dry::Monads::Either] the result of the function.
  def self.call(group:, output:)
    Right(
      group
        .fetch(
          :attributes,
          {}
        )
    )
      .bind do |group_attributes|
        Right(
          output
            .keys
            .+(group_attributes.keys)
            .zip(
              output
                .keys
                .+(group_attributes.values)
            )
        )
      end
      .bind do |unresolved_attributes|
        Try ::KeyError do
          unresolved_attributes
            .reduce ::Hash.new do |resolved_attributes, (attribute_name, output_name)|
              resolved_attributes
                .merge(
                  attribute_name
                    .to_s =>
                      output
                        .fetch(output_name.to_s)
                        .fetch("value")
                )
            end
        end
      end
      .to_either
      .or do |error|
        Left "Configuring InSpec runner attributes resulted in failure: #{error}"
      end
  end
end
