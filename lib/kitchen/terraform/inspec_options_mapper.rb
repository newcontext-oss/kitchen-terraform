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
  GROUP_TO_OPTIONS = ::Hash.new do |hash, key|
    hash.store key, key
  end

  GROUP_TO_OPTIONS.store :reporter, "reporter"

  KEYS = [:attrs, :backend, :backend_cache, :bastion_host, :bastion_port, :bastion_user, :controls, :enable_password,
          :key_files, :password, :path, :port, :proxy_command, :reporter, :self_signed, :shell, :shell_command,
          :shell_options, :user]

  def map(options:)
    KEYS.each do |key|
      if group_keys.include? key
        options.store GROUP_TO_OPTIONS.dig(key), group.fetch(key)
      end
    end
  end

  private

  attr_accessor :group, :group_keys

  def initialize(group:)
    self.group = group
    self.group_keys = group.keys
  end

  def store(group_key:, options:, options_key:)
    if group_keys.include? group_key
      options.store options_key, group.fetch(group_key)
    end
  end
end
