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

# Configures the private SSH key to be used by the verifier's InSpec Runner to verify a group.
#
# The default value is the Test Kitchen SSH Transport's +:ssh_key+ configuration attribute.
#
# @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb InSpec Runner
# @see https://github.com/test-kitchen/test-kitchen/blob/v1.16.0/lib/kitchen/transport/ssh.rb Test Kitchen SSH Transport
module ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerSSHKey
  extend ::Dry::Monads::Maybe::Mixin

  # Invoke the function.
  #
  # @param group [::Hash] the group being verified.
  # @param options [::Hash] the Inspec::Runner's options.
  def self.call(group:, options:)
    Maybe(group[:ssh_key])
      .bind do |ssh_key|
        options
          .store(
            "key_files",
            [ssh_key]
          )
      end
  end
end
