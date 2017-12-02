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

require "kitchen/verifier/terraform"

# Configures the user for the Inspec::Runner used by the verifier to verify a group.
#
# The default user is the transport's +:username+.
#
# @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb Inspec::Runner
module ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser
  # Invoke the function.
  #
  # @param group [::Hash] the group being verified.
  # @param options [::Hash] the Inspec::Runner's options.
  def self.call(group:, options:)
    group[:username]
      .tap do |username|
        username and
          options
            .store(
              "user",
              username
            )
      end
  end
end
