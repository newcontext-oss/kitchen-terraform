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

require "delegate"
require "kitchen"
require "kitchen/terraform/deprecating"
require "thread"

class ::Kitchen::Terraform::Deprecating::KitchenInstance < DelegateClass ::Kitchen::Instance

  # Runs a given action block through a common driver mutex if required or
  # runs it directly otherwise. If a driver class' `.serial_actions` array
  # includes the desired action, then the action must be run with a muxtex
  # lock. Otherwise, it is assumed that the action can happen concurrently,
  # or fully in parallel.
  #
  # @param action [Symbol] the action to be performed
  # @param state [Hash] a mutable state hash for this instance
  # @yieldparam state [::Hash] a mutable state hash for this instance
  # @api private
  def synchronize_or_call(action, state)
    Array(
      driver
        .class
        .serial_actions
    )
      .grep action do |serial_action|
        ::Thread
          .list
          .length
          .>(1) and
            warn(
              "DEPRECATING: #{to_str} is about to invoke #{driver.class}##{serial_action} with concurrency " \
                "activated; this action will be forced to run serially as of Kitchen-Terraform v4.0.0"
            )
      end

    yield state
  end
end
