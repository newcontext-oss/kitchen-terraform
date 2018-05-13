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

require "kitchen/terraform"
require "kitchen/terraform/breaking/kitchen_instance"
require "kitchen/terraform/deprecating/kitchen_instance"
require "kitchen/terraform/version"
require "rubygems"

# This module is a factory for KitchenInstances.
#
# KitchenInstances wrap ::Kitchen::Instance in order to provide a contextual deprecation warning for actions which will
# no longer support concurrency.
module ::Kitchen::Terraform::KitchenInstance
  # Creates a new KitchenInstance.
  #
  # If the gem version satisfies the requirement of +~> 3.3+ then a breaking KitchenInstance is created.
  #
  # If the gem version satisfies the requirement of +>= 4+ then a breaking KitchenInstance is created.
  #
  # @param kitchen_instance [::Kitchen::Instance] the ::Kitchen::Instance which will act as the delegate.
  # @return [::Kitchen::Terraform::Breaking::KitchenInstance, ::Kitchen::Terraform::Deprecating::KitchenInstance] the
  #   new KitchenInstance.
  def self.new(kitchen_instance:)
    ::Kitchen::Terraform::Version
      .if_satisfies requirement: "~> 3.3" do
        return ::Kitchen::Terraform::Deprecating::KitchenInstance.new kitchen_instance
      end

    ::Kitchen::Terraform::Version
      .if_satisfies requirement: ">= 4" do
        return ::Kitchen::Terraform::Breaking::KitchenInstance.new kitchen_instance
      end
  end
end
