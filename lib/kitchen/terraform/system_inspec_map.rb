# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

module Kitchen
  module Terraform
    # SYSTEM_INSPEC_MAP is a mapping of system configuration attribute keys to InSpec option keys.
    SYSTEM_INSPEC_MAP = {
      attrs: :input_file,
      backend_cache: :backend_cache,
      backend: :backend,
      bastion_port: :bastion_port,
      bastion_user: :bastion_user,
      color: "color",
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
  end
end
