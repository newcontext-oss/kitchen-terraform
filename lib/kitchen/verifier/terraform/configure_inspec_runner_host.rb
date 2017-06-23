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

# Configures the host for the Inspec::Runner used by the verifier to verify a group's host.
#
# @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb Inspec::Runner
module ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost
  # Invokes the function.
  #
  # @param hostname [::String] the hostname of a group's host.
  # @param options [::Hash] the Inspec::Runner's options.
  def self.call(hostname:, options:)
    options.store "host", hostname
  end
end
