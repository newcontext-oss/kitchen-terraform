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

# Kitchen::Terraform::InSpecOptionsMapper maps system configuration attributes to an InSpec options hash.
class ::Kitchen::Terraform::InSpecOptionsMapper
  SYSTEM_ATTRIBUTES_TO_OPTIONS = {
    attrs: :input_file,
    backend_cache: :backend_cache,
    backend: :backend,
    bastion_host: :bastion_host,
    bastion_port: :bastion_port,
    bastion_user: :bastion_user,
    controls: :controls,
    enable_password: :enable_password,
    key_files: :key_files,
    password: :password,
    path: :path,
    port: :port,
    proxy_command: :proxy_command,
    reporter: "reporter",
    self_signed: :self_signed,
    shell_command: :shell_command,
    shell_options: :shell_options,
    shell: :shell,
    show_progress: :show_progress,
    ssl: :ssl,
    sudo_command: :sudo_command,
    sudo_options: :sudo_options,
    sudo_password: :sudo_password,
    sudo: :sudo,
    user: :user,
    vendor_cache: :vendor_cache,
  }

  # map populates an InSpec options hash based on the intersection between the system keys and the supported options
  # keys, converting keys from symbols to strings as required by InSpec.
  #
  # @param options [::Hash] the InSpec options hash to be populated.
  # @return [void]
  def map(options:, system:)
    system.lazy.select do |attribute_name, _|
      system_attributes_to_options.key?(attribute_name)
    end.each do |attribute_name, attribute_value|
      options.store system_attributes_to_options.fetch(attribute_name), attribute_value
    end

    options
  end

  private

  attr_accessor :system_attributes_to_options

  # @api private
  def initialize
    self.system_attributes_to_options = ::Kitchen::Terraform::InSpecOptionsMapper::SYSTEM_ATTRIBUTES_TO_OPTIONS.dup
  end
end
