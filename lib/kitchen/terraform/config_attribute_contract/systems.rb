# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "dry/validation"

module Kitchen
  module Terraform
    module ConfigAttributeContract
      # Systems is the class of objects that provide a configuration attribute contract for systems.
      class Systems < ::Dry::Validation::Contract
        schema do
          required(:value).array(:hash) do
            required(:name).filled :str?
            required(:backend).filled :str?
            optional(:attrs).array(:filled?, :str?)
            optional(:attrs_outputs).filled :hash?
            optional(:backend_cache).value :bool?
            optional(:bastion_host).filled :str?
            optional(:bastion_host_output).filled :str?
            optional(:bastion_port).value :int?
            optional(:bastion_user).filled :str?
            optional(:controls).array(:filled?, :str?)
            optional(:enable_password).filled :str?
            optional(:hosts).array :filled?, :str?
            optional(:hosts_output).filled :str?
            optional(:key_files).array(:filled?, :str?)
            optional(:password).filled :str?
            optional(:path).filled :str?
            optional(:port).value :int?
            optional(:profile_locations).array :filled?, :str?
            optional(:proxy_command).filled :str?
            optional(:reporter).array(:filled?, :str?)
            optional(:self_signed).value :bool?
            optional(:shell).value :bool?
            optional(:shell_command).filled :str?
            optional(:shell_options).filled :str?
            optional(:show_progress).value :bool?
            optional(:ssl).value :bool?
            optional(:sudo).value :bool?
            optional(:sudo_command).filled :str?
            optional(:sudo_options).filled :str?
            optional(:sudo_password).filled :str?
            optional(:user).filled :str?
            optional(:vendor_cache).filled :str?
          end
        end
      end
    end
  end
end
