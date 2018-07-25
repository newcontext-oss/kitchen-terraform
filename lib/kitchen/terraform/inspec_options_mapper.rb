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

# Kitchen::Terraform::InSpecOptionsMapper maps group configuration attributes to an InSpec options hash.
class ::Kitchen::Terraform::InSpecOptionsMapper
  # map populates an InSpec options hash based on the intersection between the group keys and the supported options
  # keys, converting keys from symbols to strings as required by InSpec.
  #
  # @param options [::Hash] the InSpec options hash to be populated.
  # @return [void]
  def map(options:)
    group_keys.&(options_keys).each do |key|
      options.store group_to_options.dig(key), group.fetch(key)
    end
  end

  private

  attr_accessor :group, :group_keys, :group_to_options, :options_keys

  # @api private
  def initialize(group:)
    self.group = group
    self.group_keys = group.keys
    self.group_to_options = ::Hash.new do |hash, key|
      hash.store key, key
    end
    group_to_options.store :reporter, "reporter"
    self.options_keys = [:attrs, :backend, :backend_cache, :bastion_host, :bastion_port, :bastion_user, :controls,
                         :enable_password, :key_files, :password, :path, :port, :proxy_command, :reporter, :self_signed,
                         :shell, :shell_command, :shell_options, :show_progress, :ssl, :sudo, :sudo_command,
                         :sudo_options, :sudo_password, :user, :vendor_cache]
  end
end
