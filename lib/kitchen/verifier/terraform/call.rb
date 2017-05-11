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

require "kitchen"
require "kitchen/verifier/terraform"
require "kitchen/verifier/terraform/enumerate_group_hosts"

::Kitchen::Verifier::Terraform::Call = lambda do |state|
  begin
    config.fetch(:groups).each do |group|
      state.store :group, group
      ::Kitchen::Verifier::Terraform::EnumerateGroupHosts.call client: silent_client, group: group do |host:|
        state.store :host, host
        info "Verifying '#{host}' of group '#{group.fetch :name}'"
        super state
      end
    end
  rescue ::Kitchen::StandardError, ::SystemCallError => error
    raise ::Kitchen::ActionFailed, error.message
  end
end
