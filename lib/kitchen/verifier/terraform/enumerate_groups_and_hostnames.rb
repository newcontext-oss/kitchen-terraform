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

require "dry/monads"
require "kitchen/verifier/terraform"

# Enumerates each group and the hostnames of each group.
#
# If a group associates +:hostnames+ with a value then that value is assumed to be the name of a Terraform output
# variable which has a value of a string or array containing one or more hostnames; those hostnames will be enumerated
# with the group.
#
# If a group omits +:hostnames+ then the hostname +"localhost"+ will be enumerated with that group; this hostname will
# cause the InSpec profile to be executed locally and enable verification of resources in the Terraform state without
# the use of Secure Shell (SSH).
#
# @see https://en.wikipedia.org/wiki/Secure_Shell Secure Shell
# @see https://www.terraform.io/docs/configuration/outputs.html Terraform output variables
# @see https://www.terraform.io/docs/state/index.html Terraform state
module ::Kitchen::Verifier::Terraform::EnumerateGroupsAndHostnames
  extend ::Dry::Monads::Either::Mixin
  extend ::Dry::Monads::List::Mixin
  extend ::Dry::Monads::Maybe::Mixin
  extend ::Dry::Monads::Try::Mixin

  # Invokes the function.
  #
  # @param driver [::Kitchen::Driver::Terraform] a kitchen-terraform driver.
  # @param groups [::Array] a collection of groups.
  # @return [::Dry::Monads::Either] the result of the function.
  # @yieldparam group [::Hash] the group from which hostnamess are being enumerated.
  # @yieldparam hostname [::String] a hostname from the group.
  def self.call(driver:, groups:, &block)
    List(groups).fmap(&method(:Right)).typed(::Dry::Monads::Either).traverse do |member|
      member.bind do |group|
        if group.key? :hostnames
          driver.output.bind do |output|
            Try ::KeyError do
              Array(output.fetch(group.fetch(:hostnames)).fetch("value")).each do |hostname|
                block.call group: group, hostname: hostname
              end
            end.to_either.or do |error|
              Left error.to_s
            end
          end
        else
          Right block.call group: group, hostname: "localhost"
        end
      end
    end.bind do
      Right "finished enumeration of groups and hostnames"
    end
  end
end
